//
//  ZDInvocationWrapper.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/9/20.
//

#import "ZDInvocationWrapper.h"
#import <objc/runtime.h>

@implementation ZDInvocationWrapper

+ (id)zd_target:(id)target invokeSelectorWithArgs:(SEL)selector, ... {
    va_list args;
    va_start(args, selector);
    id result = [self zd_target:target invokeSelector:selector args:args];
    va_end(args);
    
    return result;
}

+ (id)zd_target:(id)target invokeSelector:(SEL)selector args:(va_list)args {
    if (![target respondsToSelector:selector]) {
        NSAssert2(NO, @"%@ doesNotRecognizeSelector: %@", target, NSStringFromSelector(selector));
        return nil;
    }
    
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    
    [self buildInvocation:invocation singature:signature args:args];
    
    [invocation invoke];
    
    id result = [self returnValueWithInvocation:invocation singature:signature];
    return result;
}

#pragma mark - Private

+ (void)buildInvocation:(NSInvocation *)invocation singature:(NSMethodSignature *)signature args:(va_list)args {
    NSUInteger argsCount = signature.numberOfArguments;
    for (NSUInteger index = 2; index < argsCount; ++index) {
        const char *argType = [signature getArgumentTypeAtIndex:index];
        while (*argType == _C_CONST || // const
               *argType == 'n' || // in
               *argType == 'N' || // inout
               *argType == 'o' || // out
               *argType == 'O' || // bycopy
               *argType == 'R' || // byref
               *argType == 'V') { // oneway
            argType++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*argType) {
            case _C_VOID:
            case _C_BOOL:
            case _C_CHR:
            case _C_UCHR:
            case _C_SHT:
            case _C_USHT:
            case _C_INT:
            case _C_UINT:
            case _C_LNG:
            case _C_ULNG: {
                int arg = va_arg(args, int);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_FLT: {
                double arg = va_arg(args, double);
                float argf = arg;
                [invocation setArgument:&argf atIndex:index];
            } break;
            case _C_DBL: {
                double arg = va_arg(args, double);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_LNG_LNG:
            case _C_ULNG_LNG: {
                long long arg = va_arg(args, long long);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case 'D': {
                long double arg = va_arg(args, long double);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_CHARPTR:
            case _C_PTR: {
                void *arg = va_arg(args, void *);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_SEL: {
                SEL arg = va_arg(args, SEL);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_CLASS: {
                Class arg = va_arg(args, Class);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_ID: {
                id arg = va_arg(args, id);
                [invocation setArgument:&arg atIndex:index];
            } break;
            case _C_STRUCT_B: {
                if (strcmp(argType, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [invocation setArgument:&arg atIndex:index];
                } else if (strcmp(argType, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [invocation setArgument:&arg atIndex:index];
                } else {
                    unsupportedType = YES;
                }
            } break;
            default: {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            NSUInteger size = 0;
            NSGetSizeAndAlignment(argType, &size, NULL);
            
#define case_size(_size_)                               \
    else if (size <= 4 * _size_ ) {                     \
        struct dummy {                                  \
            char tmp[4 * _size_];                       \
        };                                              \
        struct dummy arg = va_arg(args, struct dummy);  \
        [invocation setArgument:&arg atIndex:index];    \
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
                NSLog(@"ZDToolKit zd_invokeSelectorWithArgs unsupported type:%s (%lu bytes)", [signature getArgumentTypeAtIndex:index], (unsigned long)size);
            }
#undef case_size

        }
    }
}

+ (id)returnValueWithInvocation:(NSInvocation *)invocation singature:(NSMethodSignature *)signature {
    NSUInteger length = signature.methodReturnLength;
    if (length == 0) return nil;
    
    char *retType = (char *)signature.methodReturnType;
    while (*retType == _C_CONST || // const
           *retType == 'n' || // in
           *retType == 'N' || // inout
           *retType == 'o' || // out
           *retType == 'O' || // bycopy
           *retType == 'R' || // byref
           *retType == 'V') { // oneway
        retType++; // cutoff useless prefix
    }
    
    switch (*retType) {
            case _C_VOID: {
                return nil;
            } break;
            case _C_BOOL: {
                BOOL retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_CHR: {
                char retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_UCHR: {
                unsigned char retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_SHT: {
                short retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_USHT: {
                unsigned short retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_INT: {
                int retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_UINT: {
                unsigned int retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_LNG: {
                long retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_ULNG: {
                unsigned long retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_FLT: {
                float retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_DBL: {
                double retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_LNG_LNG: {
                long long retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case _C_ULNG_LNG: {
                unsigned long long retValue;
                [invocation getReturnValue:&retValue];
                return @(retValue);
            } break;
            case 'D': {
                long double retValue;
                [invocation getReturnValue:&retValue];
                return [NSNumber numberWithDouble:retValue];
            } break;
            case _C_CLASS: {
                Class retValue;
                [invocation getReturnValue:&retValue];
                return retValue;
            } break;
            case _C_ID: {
                __autoreleasing id retValue;
                [invocation getReturnValue:&retValue];
                return retValue;
            } break;
        default: {
            const char *objCType = signature.methodReturnType;
            char *buf = calloc(1, length);
            if (!buf) return nil;
            
            [invocation getReturnValue:buf];
            NSValue *retValue = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return retValue;
        } break;
    }
}


@end
