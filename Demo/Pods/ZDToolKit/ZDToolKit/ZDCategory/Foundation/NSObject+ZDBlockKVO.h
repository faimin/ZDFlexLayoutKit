//
//  NSObject+ZDBlockKVO.h
//
//  Created by Zero.D.Saber on 2017/12/10.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZDKVOChangeBlock)(id object, NSDictionary<NSKeyValueChangeKey, id> *change);

/**
 *  Block-based KVO extensions. 
 *  @warning NOT THREAD SAFE.
 */
@interface NSObject (ZDBlockKVO)

/**
 *  Add observer for changes on an object/keypath, using a change block. Will automatically remove observer when observer is deallocated.
 *
 *  @param observer The observer to add for the receiver. Used only as hash for block - not retained. Must not be nil.
 *  @param keyPath  The keypath on the receiver to observe. Must not be nil.
 *  @param options  The options for observing.
 *  @param block    The block that will be performed for KVO observation events. Must not be nil.
 */
- (void)zd_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
           changeBlock:(ZDKVOChangeBlock)block;

@end

NS_ASSUME_NONNULL_END
