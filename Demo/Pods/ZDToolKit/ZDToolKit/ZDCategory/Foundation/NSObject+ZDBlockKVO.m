//
//  NSObject+ZDBlockKVO.m
//
//  Created by Zero.D.Saber on 2017/12/10.

#import "NSObject+ZDBlockKVO.h"
#import <objc/runtime.h>

@interface ZDBlockObservation : NSObject

/// @note
/// 这里用`unsafe_unretained`而没用`weak`是因为当`observedObject`即将释放时(e.g:在`observedObject`的`dealloc`方法里),
/// `observedObject`就已经变为`nil`了,虽然`observedObject`还没有真正释放吧(`observedObject`会先释放其关联对象后才会释放),
/// 这样就会导致在`ZDBlockObservation`的`dealloc`方法中无法移除观察者了。
@property (nonatomic, unsafe_unretained) NSObject *observedObject;
@property (nonatomic, unsafe_unretained) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) ZDKVOChangeBlock block;

- (instancetype)initWithObservedObject:(NSObject *)object
                              observer:(NSObject *)observer
                               keyPath:(NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                                 block:(ZDKVOChangeBlock)block;

@end

// -------------

@implementation NSObject (ZDBlockKVO)

- (void)zd_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
           changeBlock:(ZDKVOChangeBlock)block {
    if (!observer || !keyPath) return;
    
    ZDBlockObservation *observation = [[ZDBlockObservation alloc] initWithObservedObject:self observer:observer keyPath:keyPath options:options block:block];
    objc_setAssociatedObject(self, keyPath.UTF8String, observation, OBJC_ASSOCIATION_RETAIN);
}

@end

// ----------

@implementation ZDBlockObservation

- (void)dealloc {
    if ( self.observedObject ) {
        @try {
            [self.observedObject removeObserver:self forKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
    }
}

- (instancetype)initWithObservedObject:(NSObject *)object
                              observer:(NSObject *)observer
                               keyPath:(NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                                 block:(ZDKVOChangeBlock)block {
    if ( self = [super init] ) {
        self.observedObject = object;
        self.observer = observer;
        self.keyPath = keyPath;
        self.block = block;
        
        [object addObserver:self forKeyPath:keyPath options:options context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if ( self.block ) {
        self.block(object, change);
    }
}

@end
