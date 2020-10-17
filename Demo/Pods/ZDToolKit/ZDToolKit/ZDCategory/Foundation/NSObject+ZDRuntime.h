//
//  NSObject+Runtime.h
//  ZDUtility
//
//  Created by Zero on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//
//  PS: most of methods from DTFoundation: https://github.com/Cocoanetics/DTFoundation


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZD_FreeBlock)(id realTarget);

@interface NSObject (ZDRuntime)

#pragma mark - Dealloc Block
/**
 Adds a block to be executed as soon as the receiver's memory is deallocated
 @param block The block to execute when the receiver is being deallocated
 */
- (void)addDeallocBlock:(dispatch_block_t)block;

/// deallocBlock executed after the object dealloc
- (void)zd_deallocBlcok:(ZD_FreeBlock)deallocBlock;

#pragma mark - Swizzeling

/**
 Adds a new instance method to a class. All instances of this class will have this method.
 
 The block captures `self` in the calling context. To allow access to the instance from within the block it is passed as parameter to the block.
 @param selectorName The name of the method.
 @param block The block to execute for the instance method, a pointer to the instance is passed as the only parameter.
 @returns `YES` if the operation was successful
 */
+ (BOOL)zd_addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block;

/**
 Exchanges two method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)zd_swizzleInstanceMethod:(SEL)selector withMethod:(SEL)otherSelector;

/**
 Exchanges two class method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)zd_swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector;


#pragma mark - Associate

- (void)zd_setStrongAssociateValue:(nullable id)value forKey:(const void *)key;
- (nullable id)zd_getStrongAssociatedValueForKey:(const void *)key;

- (void)zd_setCopyAssociateValue:(nullable id)value forKey:(const void *)key;
- (nullable id)zd_getCopyAssociatedValueForKey:(const void *)key;

- (void)zd_setWeakAssociateValue:(id)value forKey:(const void *)key;
- (nullable id)zd_getWeakAssociateValueForKey:(const void *)key;

- (void)zd_setUnsafeUnretainedAssociateValue:(nullable id)value forKey:(const void *)key;
- (nullable id)zd_getUnsafeUnretainedAssociatedValueForKey:(const void *)key;

- (void)zd_removeAssociatedValues;

@end

//==========================================================

/**
 This class is used by [NSObject addDeallocBlock:] to execute blocks on dealloc
 */

@interface ZDObjectBlockExecutor : NSObject

/**
 Convenience method to create a block executor with a deallocation block
 @param block The block to execute when the created receiver is being deallocated
 */
+ (instancetype)blockExecutorWithDeallocBlock:(dispatch_block_t)block;

/**
 Block to execute when dealloc of the receiver is called
 */
@property (nonatomic, copy) dispatch_block_t deallocBlock;

@end

//========================================================
#pragma mark ZDWeakSelf
//========================================================
@interface ZDWeakSelf : NSObject

@property (nonatomic, copy, readonly) ZD_FreeBlock deallocBlock;
@property (nonatomic, unsafe_unretained, readonly) id realTarget;

- (instancetype)initWithBlock:(ZD_FreeBlock)deallocBlock realTarget:(id)realTarget;

@end

NS_ASSUME_NONNULL_END
