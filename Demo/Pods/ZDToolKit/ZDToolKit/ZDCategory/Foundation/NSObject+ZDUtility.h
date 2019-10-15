//
//  NSObject+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZDUtility)

+ (nullable instancetype)zd_cast:(id)objc;

- (nullable instancetype)zd_deepCopy;

- (nullable id)zd_invokeSelectorWithArgs:(SEL)selector, ...;

@end

NS_ASSUME_NONNULL_END
