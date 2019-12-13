//
//  ZDBlock.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import "ZDBlockHook.h"
#import <objc/message.h>
#import <objc/runtime.h>
#if __has_include(<ffi.h>)
#import <ffi.h>
#elif __has_include("ffi.h")
#import "ffi.h"
#endif

#pragma mark - Block Define
#pragma mark -

// http://clang.llvm.org/docs/Block-ABI-Apple.html#high-level
// https://opensource.apple.com/source/libclosure/libclosure-67/Block_private.h.auto.html
// Values for Block_layout->flags to describe block objects
typedef NS_OPTIONS(NSUInteger, ZDBlockDescriptionFlags) {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

// revised new layout

#define BLOCK_DESCRIPTOR_1 1
struct ZDBlock_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};

#define BLOCK_DESCRIPTOR_2 1
struct ZDBlock_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
};

#define BLOCK_DESCRIPTOR_3 1
struct ZDBlock_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};

struct ZDBlock_layout {
    void *isa;  // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    volatile int flags; // contains ref count
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 *descriptor;
    // imported variables
};

typedef struct ZDBlock_layout ZDBlock;

#pragma mark - Function
#pragma mark -

/// 不能直接通过blockRef->descriptor->signature获取签名，因为不同场景下的block结构有差别:
/// 比如当block内部引用了外面的局部变量，并且这个局部变量是OC对象，
/// 或者是`__block`关键词包装的变量，block的结构里面有copy和dispose函数，因为这两种变量都是属于内存管理的范畴的；
/// 其他场景下的block就未必有copy和dispose函数。
/// 所以这里是通过flag判断是否有签名，以及是否有copy和dispose函数，然后通过地址偏移找到signature的。
const char *ZD_BlockSignatureTypes(id block) {
    if (!block) return NULL;
    
    ZDBlock *blockRef = (__bridge ZDBlock *)block;
    
    // unsigned long int size = blockRef->descriptor->size;
    ZDBlockDescriptionFlags flags = blockRef->flags;
    
    if ( !(flags & BLOCK_HAS_SIGNATURE) ) return NULL;
    
    void *signatureLocation = blockRef->descriptor;
    signatureLocation += sizeof(unsigned long int);
    signatureLocation += sizeof(unsigned long int);
    
    if (flags & BLOCK_HAS_COPY_DISPOSE) {
        signatureLocation += sizeof(void(*)(void *dst, void *src));
        signatureLocation += sizeof(void(*)(void *src));
    }
    
    const char *signature = (*(const char **)signatureLocation);
    return signature;
}

ZDBlockIMP ZD_BlockInvokeIMP(id block) {
    if (!block) return NULL;
    
    ZDBlock *blockRef = (__bridge ZDBlock *)block;
    return blockRef->invoke;
}

// https://github.com/bang590/JSPatch/blob/master/JSPatch/JPEngine.m
IMP ZD_MsgForwardIMP(const char *methodTypes) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    if (methodTypes[0] == '{') {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodTypes];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    return msgForwardIMP;
}

BOOL ZD_IsMsgForwardIMP(IMP imp) {
    return (imp == _objc_msgForward
#if !defined(__arm64__)
            || imp == _objc_msgForward_stret
#endif
            );
}

NSString *ZD_ReduceBlockSignatureCodingType(const char *signatureCodingType) {
    NSString *charType = [NSString stringWithUTF8String:signatureCodingType];
    if (charType.length == 0) return nil;
    
    NSString *codingType = charType.copy;
    
    NSError *error = nil;
    NSString *regexString = @"\\\"[A-Za-z]+\\\"|\\\"<[A-Za-z]+>\\\"|[0-9]+";// <==> \\"[A-Za-z]+\\"|\d+  <==>  \\"\w+\\"|\\\"<w+>\\\"|\d+
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    
    NSTextCheckingResult *mathResult = nil;
    do {
        mathResult = [regex firstMatchInString:codingType options:NSMatchingReportProgress range:NSMakeRange(0, codingType.length)];
        if (mathResult.range.location != NSNotFound && mathResult.range.length != 0) {
            codingType = [codingType stringByReplacingCharactersInRange:mathResult.range withString:@""];
        }
    } while (mathResult.range.length != 0);
    
    return codingType;
}

#pragma mark -

static id ZD_ArgumentOfInvocationAtIndex(NSInvocation *invocation, NSUInteger index) {
#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[invocation getArgument:&val atIndex:(NSInteger)index]; \
return @(val); \
} while (0)
    
    const char *originArgType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    NSString *argTypeString = ZD_ReduceBlockSignatureCodingType(originArgType);
    const char *argType = argTypeString.UTF8String;
    
    // Skip const type qualifier.
    if (argType[0] == 'r') {
        argType++;
    }
    
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id argValue;
        [invocation getArgument:&argValue atIndex:(NSInteger)index];
        return argValue;
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [invocation getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [invocation getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    
    return nil;
#undef WRAP_AND_RETURN
}
/*
#pragma mark -

@interface NSInvocation (PrivateAPI)
- (void)invokeUsingIMP:(IMP)imp;
@end
*/

#pragma mark - -------------------- MessageForward ------------------------
#pragma mark - Hook Block

static const void *ZD_Origin_Block_Key = &ZD_Origin_Block_Key;

//---------------------------------------------------------------------------------
static NSMethodSignature *ZD_NewSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    const char *blockSignature = ZD_BlockSignatureTypes(self);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:blockSignature];
    return signature;
}

static void ZD_NewForwardInvocation(id self, SEL _cmd, NSInvocation *anInvocation) {
    __unused ZDBlock *layout = (__bridge void *)anInvocation.target;
    __unused SEL selector = anInvocation.selector;
    
    for (NSInteger i = 1; i < anInvocation.methodSignature.numberOfArguments; ++i) {
        id argValue = ZD_ArgumentOfInvocationAtIndex(anInvocation, i);
        NSLog(@"block arg ==> index: %ld, value: %@", i, argValue);
    }
    
    id originBlock = objc_getAssociatedObject(self, ZD_Origin_Block_Key);
    [anInvocation setTarget:originBlock];
    //[anInvocation invokeUsingIMP:(IMP)((__bridge ZDBlock *)originBlock)->invoke];
    [anInvocation invoke];
}
//---------------------------------------------------------------------------------

static NSString *const ZD_Prefix = @"ZD_";

id ZD_HookBlock(id block) {
    if (![block isKindOfClass:objc_lookUpClass("NSBlock")]) return block;
    
    const char *blockClassName = object_getClassName(block);
    Class newBlockClass = object_getClass(block);
    if (![[NSString stringWithUTF8String:blockClassName] hasPrefix:ZD_Prefix]) {
        const char *prefix = ZD_Prefix.UTF8String;
        char *newBlockClassName = calloc(1, strlen(prefix) + strlen(blockClassName) + 1);//+1 for the zero-terminator
        strcpy(newBlockClassName, prefix);
        strcat(newBlockClassName, blockClassName);
        
        newBlockClass = objc_lookUpClass(newBlockClassName);
        if (!newBlockClass) {
            Class aClass = object_getClass(block);
            newBlockClass = objc_allocateClassPair(aClass, newBlockClassName, 0);
            {
                SEL selector = @selector(methodSignatureForSelector:);
                // 当前类自身没有实现这个method，所以下面获取到的其实是父类的方法
                Method method = class_getInstanceMethod(newBlockClass, selector);
                // 因为当前类自己没有实现这个method，所以执行class_replaceMethod就等价于class_addMethod，所以在这里直接使用class_replaceMethod方法也没毛病
                if (class_addMethod(newBlockClass, selector, (IMP)ZD_NewSignatureForSelector, method_getTypeEncoding(method))) {
                    // return originIMP
                    class_replaceMethod(newBlockClass, selector, (IMP)ZD_NewSignatureForSelector, method_getTypeEncoding(method));
                }
            }
            
            {
                SEL selector = @selector(forwardInvocation:);
                Method method = class_getInstanceMethod(newBlockClass, selector);
                if (class_addMethod(newBlockClass, selector, (IMP)ZD_NewForwardInvocation, method_getTypeEncoding(method))) {
                    class_replaceMethod(newBlockClass, selector, (IMP)ZD_NewForwardInvocation, method_getTypeEncoding(method));
                }
            }
            objc_registerClassPair(newBlockClass);
        }

        free(newBlockClassName);
    }
    
    ZDBlock *blockRef = (__bridge ZDBlock *)block;
    if (!blockRef) return NULL;
    
    // create a new block
    ZDBlock *fakeBlock = calloc(1, sizeof(ZDBlock));
    fakeBlock->isa = (__bridge void *)newBlockClass;
    fakeBlock->reserved = blockRef->reserved;
    fakeBlock->flags = blockRef->flags;
    fakeBlock->descriptor = blockRef->descriptor;
    if (blockRef->flags & BLOCK_USE_STRET) {
#if !defined(__arm64__)
        fakeBlock->invoke = (void *)(IMP)_objc_msgForward_stret;
#endif
    }
    else {
        fakeBlock->invoke = (void *)(IMP)_objc_msgForward;
    }
    objc_setAssociatedObject((__bridge id _Nonnull)(fakeBlock), ZD_Origin_Block_Key, (__bridge id _Nullable)(blockRef), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return (__bridge_transfer id)fakeBlock;
}

#pragma mark - ------------------------------- Libffi ----------------------------------
#pragma mark -

#if USE_LIBFFI
static ffi_type *ZD_ffiTypeWithTypeEncoding(const char *type) {
    if (strcmp(type, "@?") == 0) { // block
        return &ffi_type_pointer;
    }
    const char *c = type;
    switch (c[0]) {
        case 'v':
            return &ffi_type_void;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'F':
#if CGFLOAT_IS_DOUBLE
            return &ffi_type_double;
#else
            return &ffi_type_float;
#endif
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
        case ':':
            return &ffi_type_schar;
        case '*':
            return &ffi_type_pointer;
        case '{':
        default: {
            printf("not support the type: %s", c);
        } break;
    }
    
    NSCAssert(NO, @"can't match a ffi_type of %s", type);
    return NULL;
}

//*****************************************

@interface NSObject (ZDBKWeakBinding)
@property (nonatomic, weak) id zdbk_weakBindValue;
@end

@implementation NSObject (ZDBKWeakBinding)
- (void)setZdbk_weakBindValue:(id)zdbk_weakBindValue {
    if (zdbk_weakBindValue) {
        __weak id weakValue = zdbk_weakBindValue;
        objc_setAssociatedObject(self, @selector(zdbk_weakBindValue), ^id{
            return weakValue;
        }, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    else {
        objc_setAssociatedObject(self, @selector(zdbk_weakBindValue), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (id)zdbk_weakBindValue {
    id (^block)(void) = objc_getAssociatedObject(self, _cmd);
    return block ? block() : nil;
}
@end

@interface ZDFfiBlockHook () {
    @package
    ffi_cif _blockCif;
    ffi_type **_blockArgs;
    ffi_closure *_closure;
    
    void *_originalIMP;
    void *_newIMP;
}
@property (nonatomic, strong) NSMethodSignature *signature;
@property (nonatomic, copy) NSString *typeEncoding;
@property (nonatomic, weak) id block;
@end

//********************************** 函数 ****************************************

static id ZD_ArgumentAtIndex(NSMethodSignature *methodSignature, void *ret, void **args, void *userdata, NSUInteger index) {
#define WRAP_AND_RETURN(type) \
do { \
type val = *((type *)args[index]);\
return @(val); \
} while (0)
    
    const char *originArgType = [methodSignature getArgumentTypeAtIndex:index];
    NSString *argTypeString = ZD_ReduceBlockSignatureCodingType(originArgType);
    const char *argType = argTypeString.UTF8String;
    
    // Skip const type qualifier.
    if (argType[0] == 'r') {
        argType++;
    }
    
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        id argValue = (__bridge id)(*((void **)args[index]));
        return argValue;
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        block = (__bridge id)(*((void **)args[index]));
        return [block copy];
    }
    /*
    else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [invocation getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
     */
    
    return nil;
#undef WRAP_AND_RETURN
}

static void ZD_ffi_prep_cif(NSMethodSignature *signature) {
    ZDFfiBlockHook *self = (ZDFfiBlockHook *)(signature.zdbk_weakBindValue);
    
    ffi_type *returnType = ZD_ffiTypeWithTypeEncoding(signature.methodReturnType);
    NSCAssert(returnType, @"can't find a ffi_type ==> %s", signature.methodReturnType);
    
    NSUInteger argCount = signature.numberOfArguments; // 第一个参数是block自己，第二个参数才是我们看到的参数
    //ffi_type **args = alloca(sizeof(ffi_type *) * argCount); // 栈上开辟内存
    ffi_type **args = calloc(argCount, sizeof(ffi_type *)); // 堆上开辟内存
    for (int i = 0; i < argCount; ++i) {
        const char *realArgType = [signature getArgumentTypeAtIndex:i];
        const char *reducedArgType = ZD_ReduceBlockSignatureCodingType(realArgType).UTF8String;
        ffi_type *arg_ffi_type = ZD_ffiTypeWithTypeEncoding(reducedArgType);
        NSCAssert(arg_ffi_type, @"can't find a ffi_type ==> %s", realArgType);
        args[i] = arg_ffi_type;
    }
    self->_blockArgs = args;
    
    //生成ffi_cfi模版对象，保存函数参数个数、类型等信息，相当于一个函数原型
    ffi_status status = ffi_prep_cif(&(self->_blockCif), FFI_DEFAULT_ABI, (unsigned int)argCount, returnType, args);
    if (status != FFI_OK) {
        NSCAssert1(NO, @"Got result %u from ffi_prep_cif", status);
    }
}

// block回调时会执行的函数
static void ZD_ffi_closure_func(ffi_cif *cif, void *ret, void **args, void *userdata) {
    ZDFfiBlockHook *self = (__bridge ZDFfiBlockHook *)userdata;
    
#if (DEBUG && 0)
    int i = *((int *)args[2]);
    NSString *str = (__bridge NSString *)(*((void **)args[1]));
    NSLog(@"%d, %@", i, str);
#endif
    
    NSMethodSignature *methodSignature = self.signature;
    for (NSInteger i = 1; i < methodSignature.numberOfArguments; ++i) {
        id argValue = ZD_ArgumentAtIndex(methodSignature, ret, args, userdata, i);
        NSLog(@"block arg ==> index: %ld, value: %@", i, argValue);
    }
    
    // https://github.com/sunnyxx/libffi-iOS/blob/master/Demo/ViewController.m
    // 根据cif (函数原型，函数指针，返回值内存指针，函数参数) 调用这个函数
    ffi_call(&(self->_blockCif), self->_originalIMP, ret, args);
    
    // 执行完毕之后恢复为原来的IMP
    ((__bridge ZDBlock *)self.block)->invoke = self->_originalIMP;
}

static void ZD_ffi_prep_closure(NSMethodSignature *signature) {
    ZDFfiBlockHook *self = (ZDFfiBlockHook *)(signature.zdbk_weakBindValue);
    
    // https://blog.cnbang.net/tech/3332/
    // https://github.com/sunnyxx/libffi-iOS/blob/master/Demo/ViewController.m
    ZDBlockIMP newBlockIMP = NULL;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&newBlockIMP);
    ffi_status status = ffi_prep_closure_loc(closure, &(self->_blockCif), ZD_ffi_closure_func, (__bridge void *)self, newBlockIMP);
    if (status != FFI_OK) {
        NSCAssert(NO, @"genarate closure failed");
    }

    self->_closure = closure;
    self->_newIMP = newBlockIMP;
    ((__bridge ZDBlock *)self.block)->invoke = newBlockIMP;
}

static void ZD_HookBlockWithSignature(NSMethodSignature *signature) {
    ZD_ffi_prep_cif(signature);
    ZD_ffi_prep_closure(signature);
}

static void ZD_HookBlockWithLibffi(id block) {
    const char *blockTypeEncoding = ZD_BlockSignatureTypes(block);
    NSString *blockTypeEncodingString = ZD_ReduceBlockSignatureCodingType(blockTypeEncoding);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:blockTypeEncodingString.UTF8String];
    
    ZD_HookBlockWithSignature(signature);
}

#pragma mark -

@implementation ZDFfiBlockHook

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    ffi_closure_free(_closure);
    free(_blockArgs);
}

+ (instancetype)hookBlock:(id)block {
    ZDFfiBlockHook *blockHook = [[ZDFfiBlockHook alloc] init];
    blockHook.block = block;
    const char *typeEncoding = ZD_ReduceBlockSignatureCodingType(ZD_BlockSignatureTypes(block)).UTF8String;
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
    signature.zdbk_weakBindValue = blockHook;
    blockHook.signature = signature;
    blockHook.typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    blockHook->_originalIMP = ZD_BlockInvokeIMP(block);
    
    ZD_HookBlockWithLibffi(block);
    
    return blockHook;
}

@end
#endif // USE_LIBFFI


#pragma mark - +++++++++++++++++++++++整合+++++++++++++++++++++++++++++
#pragma mark -

#import "NSObject+ZDRuntime.h"
@implementation NSObject (ZDHookBlock)

- (void)zd_hookBlock:(id *)block hookWay:(ZDHookWay)hookWay {
    if (!block || !*block) return;
    
    switch (hookWay) {
        case ZDHookWay_Libffi: {
            __block ZDFfiBlockHook *ffiHook = [ZDFfiBlockHook hookBlock:*block];
            [self zd_deallocBlock:^(id  _Nonnull realTarget) {
                // 释放ffiHook
                ffiHook = nil;
            }];
        } break;
        default: {
            *block = ZD_HookBlock(*block);
        } break;
    }
}

@end
