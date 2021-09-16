//
//  NSObject+ZDFlexLayoutFrameCache.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/11/19.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZDFlexLayoutFrameCache)

@property (nonatomic, assign) CGRect zd_cachedLayoutFrame;

@property (nonatomic, strong) NSArray<NSValue *> *zd_cachedViewLayoutFrames;

@end

NS_ASSUME_NONNULL_END
