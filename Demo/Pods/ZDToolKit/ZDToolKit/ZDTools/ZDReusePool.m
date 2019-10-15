//
//  ReuseObject.m
//  DittyDemo
//
//  Created by Zero.D.Saber on 2017/5/9.
//  Copyright © 2017年 Zero. All rights reserved.
//

#import "ZDReusePool.h"
#import <pthread/pthread.h>

@interface ZDReusePool ()
{
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *registeredClasses;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSSet *> *reusePool;
@end

@implementation ZDReusePool

- (void)dealloc {
    [self.registeredClasses removeAllObjects];
    [self.reusePool removeAllObjects];
    pthread_mutex_destroy(&_lock);
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
        pthread_mutex_init(&_lock, &attr);
        pthread_mutexattr_destroy(&attr);
        
        _registeredClasses = [[NSMutableDictionary alloc] init];
        _reusePool = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerClass:(nullable Class)aClass forReuseIdentifier:(NSString *)identifier {
    if (!identifier) return;
    
    pthread_mutex_lock(&_lock);
    self.registeredClasses[identifier] = aClass;
    pthread_mutex_unlock(&_lock);
}

- (id)dequeueReusableObjectWithIdentifier:(NSString *)identifier {
    NSCParameterAssert(identifier);
    if (!identifier) return nil;
    
    pthread_mutex_lock(&_lock);
    if (![self.reusePool.allKeys containsObject:identifier]) return nil;
    
    id value = nil;
    NSMutableSet *valueSet = (id)self.reusePool[identifier];
    value = [valueSet anyObject];
    if (value) {
        [valueSet removeObject:value];
    } else {
        Class aClass = self.registeredClasses[identifier];
        if (aClass) {
            value = [aClass new];
            [self addObject:value withIdentifier:identifier];
        }
    }
    
    if ([value conformsToProtocol:@protocol(ZDPrepareForReuseProtocol)] && [value respondsToSelector:@selector(prepareForReuse)]) {
        [value prepareForReuse];
    }
    pthread_mutex_unlock(&_lock);
    return value;
}

- (void)addObject:(id)object withIdentifier:(NSString *)identifier {
    if (!object || !identifier) return;
    
    NSMutableSet *mutSet = (id)self.reusePool[identifier];
    if (mutSet) {
        mutSet = [mutSet isKindOfClass:[NSMutableSet class]] ? mutSet : [NSMutableSet setWithSet:mutSet];
        [mutSet addObject:object];
    }
    else {
        mutSet = [NSMutableSet setWithObject:object];
    }
    self.reusePool[identifier] = mutSet;
}

#pragma mark - Property

@end
