//
//  NSDate+ZDUtility.h
//  Pods
//
//  Created by MOMO on 2017/6/1.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ZDUtility)

+ (NSDate *)zd_dateWithISO8601String:(NSString *)iso8601String;

@end

NS_ASSUME_NONNULL_END
