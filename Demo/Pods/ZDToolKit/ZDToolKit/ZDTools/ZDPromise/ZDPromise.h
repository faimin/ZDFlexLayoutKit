//
//  ZDPromise.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/1/20.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//
//  摘自: [promises](https://github.com/google/promises)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZDPromiseState) {
    ZDPromiseState_Pending = 0,
    ZDPromiseState_Fulfilled,
    ZDPromiseState_Rejected,
};

//***************************************************************

@interface ZDPromise<__covariant Value> : NSObject

typedef void(^ZDFulfillBlock)(Value _Nullable value);
typedef void(^ZDRejectBlock)(NSError *error);
typedef id _Nullable (^ZDThenBlock)(Value _Nullable value);
typedef void(^ZDPromiseObserver)(ZDPromiseState state, Value resolve);

@property (class, nonatomic, readonly) dispatch_group_t zd_dispatchGroup;
@property (class, nonatomic) dispatch_queue_t defaultDispatchQueue;

+ (instancetype)async:(void(^)(ZDFulfillBlock fulfill, ZDRejectBlock reject))block;
- (instancetype)then:(ZDThenBlock)thenBlock;
- (instancetype)catch:(ZDRejectBlock)catchBlock;
+ (ZDPromise<NSArray *> *)all:(NSArray<ZDPromise *> *)allPromises;

- (BOOL)isPending;
- (BOOL)isFulfilled;
- (BOOL)isRejected;
- (nullable id)value;
- (nullable NSError *)error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

