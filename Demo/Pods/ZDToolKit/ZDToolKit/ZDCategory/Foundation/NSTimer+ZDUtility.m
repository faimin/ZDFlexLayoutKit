//
//  NSTimer+ZDUtility.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/4/13.
//
//

#import "NSTimer+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSTimer_ZDUtility)

@implementation NSTimer (ZDUtility)

#pragma mark - Public Method

+ (NSTimer *)zd_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(executeTimerBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)zd_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(executeTimerBlock:) userInfo:[block copy] repeats:repeats];
}

#pragma mark - Private Method

+ (void)executeTimerBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void(^timerBlock)(NSTimer *) = (void(^)(NSTimer *))[timer userInfo];
        timerBlock(timer);
    }
}

@end
