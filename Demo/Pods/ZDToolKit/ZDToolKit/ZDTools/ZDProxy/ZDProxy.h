//
//  ZDWeakProxy.h
//  ZDProxy
//
//  Created by Zero on 16/1/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//  https://github.com/mikeash/MAZeroingWeakRef
//  https://github.com/ibireme/YYKit/blob/master/YYKit%2FUtility%2FYYWeakProxy.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ZDWeakProxy

@interface ZDWeakProxy<__covariant TargetType : id> : NSProxy

@property (nonatomic, weak, readonly) TargetType target;

///  利用消息转发,把可能引起循环引用的target传给weakProxy,比如timer的target
///  @param target the real target of a object
///  @return instance of ZDWeakProxy that is a proxy for the real target
+ (instancetype)proxyWithTarget:(TargetType)target;

@end


#pragma mark - ZDMutiDelegatesProxy

@interface ZDMutiDelegatesProxy<__covariant TargetType : id> : NSProxy

@property (nonatomic, strong) IBOutletCollection(TargetType) NSArray<TargetType> *delegateTargets;

- (instancetype)initWithDelegates:(NSArray<TargetType> *)aDelegates;

- (void)addDelegate:(TargetType)aDelegate;

- (void)removeDelegate:(TargetType)aDelegate;

@end

NS_ASSUME_NONNULL_END

