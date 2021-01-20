//
//  ZDMeasureTaskQueue.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/21.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDCalculateHelper : NSObject

/// thread
+ (void)asyncCalculateTask:(dispatch_block_t)calculateTask onComplete:(dispatch_block_t _Nullable)onComplete;
+ (void)asyncCalculateMultiTasks:(NSArray<dispatch_block_t> *)calculateTasks onComplete:(dispatch_block_t)onComplete;

/// runloop
+ (void)asyncLayoutTask:(dispatch_block_t)layoutTask;
+ (void)removeAsyncLayoutTask:(dispatch_block_t)layoutTask;

@end

NS_ASSUME_NONNULL_END
