//
//  NSDate+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/6/1.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ZDUtility)

+ (instancetype)zd_pekingDate;

+ (instancetype)zd_dateWithISO8601String:(NSString *)iso8601String;

@end

NS_ASSUME_NONNULL_END
