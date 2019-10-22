//
//  ZDMeasureTaskQueue.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/21.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ZDCalculateFinishedNotification;

@interface ZDCalculateHelper : NSObject

+ (void)addCalculateTask:(dispatch_block_t)calculateTask;

@end

NS_ASSUME_NONNULL_END
