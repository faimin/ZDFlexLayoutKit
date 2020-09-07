//
//  NSDate+ZDUtility.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/6/1.
//
//

#import "NSDate+ZDUtility.h"
#import <time.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSDate_ZDUtility)

@implementation NSDate (ZDUtility)

+ (instancetype)zd_pekingDate {
    // 指定为东8区(北京时间)
    NSTimeZone *beijingZone = [NSTimeZone timeZoneForSecondsFromGMT:8*3600];
    // 计算本地时区与 GMT 时区的时间差
    NSInteger interval = [beijingZone secondsFromGMT];
    // 得到当前时间（世界标准时间 UTC/GMT）
    NSDate *currentDate = [NSDate date];
    // 在 GMT 时间基础上追加时间差值，得到北京时间
    currentDate = [currentDate dateByAddingTimeInterval:interval];
    return currentDate;
}

+ (instancetype)zd_dateWithISO8601String:(NSString *)iso8601String {
    time_t t;
    struct tm tm;
    strptime([iso8601String cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
    return date;
}

@end
