//
//  ZDFlexLayoutChain.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDFlexLayoutMaker.h"
#import "ZDFlexLayoutDiv.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protocol
#pragma mark -

@protocol ZDFlexLayoutChainProtocol <NSObject>
- (instancetype)zd_makeFlexLayout:(void(NS_NOESCAPE ^)(ZDFlexLayoutMaker *make))block;
@end

//*************************************************************
#pragma mark - Chain
#pragma mark -

@interface UIView (ZDFlexLayoutChain) <ZDFlexLayoutChainProtocol>

@end

@interface ZDFlexLayoutDiv (ZDFlexLayoutChain) <ZDFlexLayoutChainProtocol>

+ (instancetype)zd_makeFlexLayout:(void (NS_NOESCAPE ^)(ZDFlexLayoutMaker *))block;

@end

NS_ASSUME_NONNULL_END
