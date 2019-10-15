//
//  NSInvocation+Block.h
//  NSInvocation+Block
//
//  Created by deput on 12/11/15.
//  Copyright © 2015 deput. All rights reserved.
//  https://github.com/deput/NSInvocation-Block

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (ZDBlock)

+ (instancetype)zd_invocationWithBlock:(id)block;

+ (instancetype)zd_invocationWithBlockAndArguments:(id)block, ...;

@end

NS_ASSUME_NONNULL_END
