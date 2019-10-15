//
//  NSTimer+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/4/13.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (ZDUtility)

+ (NSTimer *)zd_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NSTimer *timer))block;

+ (NSTimer *)zd_timerWithTimeInterval:(NSTimeInterval)seconds
                              repeats:(BOOL)repeats
                                block:(void (^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
