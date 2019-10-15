//
//  ZDRunloopQueue.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2017/12/16.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//
//  copy from https://github.com/Cascable/runloop-queue

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// RunloopQueue is a serial queue based on CFRunLoop, running on the background thread.
@interface ZDRunloopQueue : NSObject

@property (nonatomic, assign, readonly) BOOL running;

- (instancetype)initWithName:(NSString *)name;
- (void)async:(void(^)(void))block;
- (void)sync:(void(^)(void))block;
- (BOOL)isRunningOnQueue;

@end

NS_ASSUME_NONNULL_END

