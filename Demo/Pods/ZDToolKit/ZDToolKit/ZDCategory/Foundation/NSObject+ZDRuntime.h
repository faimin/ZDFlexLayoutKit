//
//  NSObject+Runtime.h
//  ZDUtility
//
//  Created by Zero on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZD_DisposeBlock)(id realTarget);

@interface NSObject (ZDRuntime)

#pragma mark - Dealloc Block
/**
 Adds a block to be executed as soon as the receiver's memory is deallocated
 @param deallocBlock The block to execute when the receiver is being deallocated
 */
- (void)zd_deallocBlock:(ZD_DisposeBlock)deallocBlock;

#pragma mark - Swizzeling

/**
 Adds a new instance method to a class. All instances of this class will have this method.
 
 The block captures `self` in the calling context. To allow access to the instance from within the block it is passed as parameter to the block.
 @param selector The SEL of the method.
 @param block The block to execute for the instance method, a pointer to the instance is passed as the only parameter.
 @returns `YES` if the operation was successful
 */
+ (BOOL)zd_addInstanceMethodWithSelector:(SEL)selector block:(void(^)(id))block;

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

#pragma mark - Copy Property

- (instancetype)zd_mutableCopy;

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

#pragma mark - Print Property

+ (NSArray<NSString *> *)zd_classes;
+ (NSArray<NSString *> *)zd_subClasses;
+ (NSArray<NSString *> *)zd_properties;
+ (NSArray<NSString *> *)zd_instanceVariables;
+ (NSArray<NSString *> *)zd_classMethods;
+ (NSArray<NSString *> *)zd_instanceMethods;
+ (NSArray<NSString *> *)zd_protocols;
+ (NSDictionary<NSString *, NSArray<NSString *> *> *)zd_descriptionForProtocol:(Protocol *)protocol;
+ (NSString *)zd_parentClassHierarchy;

@end

//========================================================
#pragma mark - ZDObjectBlockExecutor
#pragma mark - 
//========================================================
/**
 This class is used by [NSObject zd_deallocBlock:] to execute blocks on dealloc
 */
@interface ZDObjectBlockExecutor : NSObject
/**
 Block to execute when dealloc of the receiver is called
 */
@property (nonatomic, copy, readonly) ZD_DisposeBlock deallocBlock;
@property (nonatomic, unsafe_unretained, readonly) id realTarget;

/**
 Convenience method to create a block executor with a deallocation block
 @param deallocBlock The block to execute when the created receiver is being deallocated
 @param realTarget The real target object
 */
- (instancetype)initWithBlock:(ZD_DisposeBlock)deallocBlock realTarget:(id)realTarget;

@end

NS_ASSUME_NONNULL_END
