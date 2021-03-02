//
//  ZDWeakProxy.m
//  ZDProxy
//
//  Created by Zero on 16/1/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
//  https://github.com/Flipboard/FLAnimatedImage/blob/76a31aefc645cc09463a62d42c02954a30434d7d/FLAnimatedImage/FLAnimatedImage.m#L786-L807
//  https://github.com/steipete/PSTDelegateProxy/blob/master/PSTDelegateProxy.m

#import "ZDProxy.h"
#import <pthread/pthread.h>

@implementation ZDWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[ZDWeakProxy alloc] initWithTarget:target];
}

#pragma mark - Forward Message

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

/// 转发到这一步一般都是由于`forwardingTargetForSelector:`返回nil
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    // We only get here if `forwardingTargetForSelector:` returns nil.
    // In that case, our weak target has been reclaimed. Return a dummy method signature to keep `doesNotRecognizeSelector:` from firing.
    // We'll emulate the ObjC messaging nil behavior by setting the return value to nil in `forwardInvocation:`, but we'll assume that the return value is `sizeof(void *)`.
    // Other libraries handle this situation by making use of a global method signature cache, but that seems heavier than necessary and has issues as well.
    // See https://www.mikeash.com/pyblog/friday-qa-2010-02-26-futures.html and https://github.com/steipete/PSTDelegateProxy/issues/1 for examples of using a method signature cache.
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

/// 转发消息,一般只有在出现`doesNotRecognizeSelector:`情况时才会执行到这个方法,此时直接返回nil
- (void)forwardInvocation:(NSInvocation *)invocation {
    // Fallback for when target is nil. Don't do anything, just return 0/NULL/nil.
    // The method signature we've received to get here is just a dummy to keep `doesNotRecognizeSelector:` from firing.
    // We can't really handle struct return types here because we don't know the length.
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

#pragma mark - NSObject Protocol

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end


#pragma mark - ************* ZDMutiDelegatesProxy *****************
#pragma mark -

@interface ZDMutiDelegatesProxy () {
    pthread_mutex_t _lock;
}
//@property (nonatomic, strong) NSHashTable *weakTargets;
@property (nonatomic, strong) NSMutableArray *weakTargets;
@end

@implementation ZDMutiDelegatesProxy

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

//MARK: Public Mehtod
- (instancetype)initWithDelegates:(NSArray *)aDelegates {
    NSCParameterAssert(aDelegates);
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    pthread_mutex_init(&_lock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    _weakTargets = [self.class weakReferenceArray];
    
    self.delegateTargets = aDelegates.copy;
    return self;
}

- (void)addDelegate:(id)aDelegate {
    NSCParameterAssert(aDelegate);
    if (!aDelegate) return;
    
    pthread_mutex_lock(&_lock);
    [_weakTargets addObject:aDelegate];
    pthread_mutex_unlock(&_lock);
    
    _delegateTargets = _weakTargets.copy;
}

- (void)removeDelegate:(id)aDelegate {
    NSCParameterAssert(aDelegate);
    if (!aDelegate) return;
    
    pthread_mutex_lock(&_lock);
    [_weakTargets removeObject:aDelegate];
    pthread_mutex_unlock(&_lock);
    
    _delegateTargets = _weakTargets.copy;
}

//MARK: Forward Message
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    else {
        for (id target in self.weakTargets) {
            if ([target respondsToSelector:aSelector]) {
                return YES;
            }
        }
        return NO;
    }
}

/// 方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [super methodSignatureForSelector:sel];
    if (!signature) {
        for (id target in self.weakTargets) {
            signature = [target methodSignatureForSelector:sel];
            if (signature) {
                break;
            }
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    for (id target in self.weakTargets) {
        if ([target respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:target];
        }
    }
}

//MARK: Property
- (void)setDelegateTargets:(NSArray *)delegateTargets {
    if (!delegateTargets) return;
    
    /*
    self.weakTargets = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
    for (id target in delegateTargets) {
        [self.weakTargets addObject:target];
    }
    */
    
    pthread_mutex_lock(&_lock);
    [_weakTargets addObjectsFromArray:delegateTargets];
    pthread_mutex_unlock(&_lock);
}

//MARK: Private Method
+ (NSMutableArray *)weakReferenceArray {
    CFArrayCallBacks callBacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return CFBridgingRelease(CFArrayCreateMutable(kCFAllocatorDefault, 0, &callBacks));
}

- (NSString *)debugDescription {
    NSString *allTargetsDebugDescription = @"";
    for (id target in self.weakTargets) {
        allTargetsDebugDescription = [NSString stringWithFormat:@"%@;\n%@", allTargetsDebugDescription, [target debugDescription]];
    }
    return allTargetsDebugDescription;
}

@end


