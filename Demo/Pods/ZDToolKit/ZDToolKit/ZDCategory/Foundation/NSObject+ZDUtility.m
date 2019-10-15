//
//  NSObject+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDUtility.h"
#import <objc/runtime.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSObject_ZDUtility)

typedef NS_ENUM(NSUInteger, PropertyType) {
    PropertyType_UnKnown,
    PropertyType_Strong,
    PropertyType_Copy,
    PropertyType_Weak,
    PropertyType_Assign,
};

@implementation NSObject (ZDUtility)

+ (instancetype)zd_cast:(id)objc {
    if (!objc) return nil;
    
    if ([objc isKindOfClass:[self class]]) {
        return objc;
    }
    return nil;
}

- (instancetype)zd_deepCopy {
    id obj = nil;
    @try {
        if (@available(iOS 11, *)) {
            NSError *error1, *error2;
            obj = [NSKeyedUnarchiver unarchivedObjectOfClass:[self class] fromData:[NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:&error1] error:&error2];
        }
        else {
            obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"deepCopy error: %@", exception);
    }
    return obj;
}

+ (BOOL)isObjectClass:(Class)clazz {
    BOOL flag = class_conformsToProtocol(clazz, @protocol(NSObject));
    if (flag) {
        return flag;
    }
    else {
        Class superClass = class_getSuperclass(clazz);
        if (!superClass) {
            return NO;
        }
        else {
            return [NSObject isObjectClass:superClass];
        }
    }
}

- (PropertyType)propertyType:(objc_property_t)property {
    unsigned int attributeCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);
    NSMutableDictionary<NSString *, NSString *> *attributes = @{}.mutableCopy;
    for (int i = 0; i < attributeCount; ++i) {
        NSString *name = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
        NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
        if (name) {
            attributes[name] = value;
        }
    }
    free(attrs);
    
    PropertyType type = PropertyType_UnKnown;
    if (attributes[@"&"]) {         ///< strong
        type = PropertyType_Strong;
    } else if (attributes[@"C"]) {  ///< copy
        type = PropertyType_Copy;
    } else if (attributes[@"W"]) {  ///< weak
        type = PropertyType_Weak;
    } else {                        ///< assign
        type = PropertyType_Assign;
    }
    return type;
}

/// 不支持block、struct、union类型
- (NSString *)decodeType:(const char *)cString {
    if (strcmp(cString, @encode(id)) == 0) return @"id";
    if (strcmp(cString, @encode(void)) == 0) return @"void";
    if (strcmp(cString, @encode(void *)) == 0) return @"void *";
    if (strcmp(cString, @encode(float)) == 0) return @"float";
    if (strcmp(cString, @encode(int)) == 0) return @"int";
    if (strcmp(cString, @encode(unsigned int)) == 0) return @"unsigned int";
    if (strcmp(cString, @encode(BOOL)) == 0) return @"BOOL";
    if (strcmp(cString, @encode(bool)) == 0) return @"bool";
    if (strcmp(cString, @encode(char *)) == 0) return @"char *";
    if (strcmp(cString, @encode(char)) == 0) return @"char";
    if (strcmp(cString, @encode(unsigned char)) == 0) return @"unsigned char";
    if (strcmp(cString, @encode(double)) == 0) return @"double";
    if (strcmp(cString, @encode(long double)) == 0) return @"long double";
    if (strcmp(cString, @encode(long)) == 0) return @"long";
    if (strcmp(cString, @encode(long long)) == 0) return @"long long";
    if (strcmp(cString, @encode(unsigned long)) == 0) return @"unsigned long";
    if (strcmp(cString, @encode(unsigned long long)) == 0) return @"unsigned long long";
    if (strcmp(cString, @encode(Class)) == 0) return @"class";
    if (strcmp(cString, @encode(SEL)) == 0) return @"SEL";
    
    NSString *classStr = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    if ([[classStr substringToIndex:1] isEqualToString:@"@"] && [classStr rangeOfString:@"?"].location == NSNotFound) {
        classStr = [[classStr substringWithRange:NSMakeRange(2, classStr.length - 3)] stringByAppendingString:@"*"];
    } else if ([[classStr substringToIndex:1] isEqualToString:@"^"]) {
        classStr = [NSString stringWithFormat:@"%@ *", [NSString decodeType:[[classStr substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
    }
    return classStr;
}

#pragma mark - Invocation

// refer: YYKit
- (id)zd_invokeSelectorWithArgs:(SEL)selector, ... {
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    if (!sig) {
        [self doesNotRecognizeSelector:selector];
        return nil;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    if (!invocation) {
        [self doesNotRecognizeSelector:selector];
        return nil;
    }
    
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    va_list args;
    va_start(args, selector);//第二个参数一定要"..."之前的那个参数
    [self.class zd_setInv:invocation withSig:sig args:args];
    va_end(args);
    
    [invocation invoke];
    id returnValue = [self.class zd_getReturnFromInv:invocation withSig:sig];
    
    return returnValue;
}

+ (void)zd_setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig args:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (NSUInteger index = 2; index < count; ++index) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == _C_CONST || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*type) {
            case _C_VOID:   // 1: void
            case _C_BOOL:   // 1: bool
            case _C_CHR:    // 1: char / BOOL
            case _C_UCHR:   // 1: unsigned char
            case _C_SHT:    // 2: short
            case _C_USHT:   // 2: unsigned short
            case _C_INT:    // 4: int / NSInteger(32bit)
            case _C_UINT:   // 4: unsigned int / NSUInteger(32bit)
            case _C_LNG:    // 4: long(32bit)
            case _C_ULNG:   // 4: unsigned long(32bit)
            { // 'char' and 'short' will be promoted to 'int'.
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_LNG_LNG: // 8: long long / long(64bit) / NSInteger(64bit)
            case _C_ULNG_LNG: // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_FLT: // 4: float / CGFloat(32bit)
            { // 'float' will be promoted to 'double'.
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
                
            case _C_DBL: // 8: double / CGFloat(64bit)
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'D': // 16: long double
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_CHARPTR: // char *
            case _C_PTR: // pointer
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_SEL: // SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_CLASS: // Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_ID: // id
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case _C_STRUCT_B: // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
                } else {
                    unsupportedType = YES;
                }
            } break;
            
            case _C_UNION_B: // union
            case _C_UNION_E:
            case _C_ARY_B:   // array
            case _C_ARY_E:
            default:         // what?!
            {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
#define case_size(_size_)       \
else if (size <= 4 * _size_ ) { \
    struct dummy {              \
        char tmp[4 * _size_];   \
    };                          \
    struct dummy arg = va_arg(args, struct dummy); \
    [inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                /*
                 Larger than 256 byte?! I don't want to deal with this stuff up...
                 Ignore this argument.
                 */
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                NSLog(@"ZDToolKit zd_invokeSelectorWithArgs unsupported type:%s (%lu bytes)", [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
            
        }
    }
}

+ (id)zd_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil; // void                       // _C_VOID
        case 'B': return_with_number(bool);                 // _C_BOOL
        case 'c': return_with_number(char);                 // _C_CHR
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(long);
        case 'L': return_with_number(unsigned long);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': { // id
            __autoreleasing id ret; //void *ret;
            [inv getReturnValue:&ret];
            return ret; //(__bridge id)ret;
        };
            
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

@end
