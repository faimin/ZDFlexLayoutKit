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

+ (void)asyncCalculateTask:(dispatch_block_t)calculateTask onComplete:(dispatch_block_t _Nullable)onComplete;

@end

NS_ASSUME_NONNULL_END
