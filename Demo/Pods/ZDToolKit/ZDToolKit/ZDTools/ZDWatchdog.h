//
//  ZDWatchdog.h
//  Pods
//
//  Created by Zero on 2016/12/8.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDWatchdog : NSObject

@property (nonatomic, assign) long long timeInterval;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shareInstance;

- (void)start;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
