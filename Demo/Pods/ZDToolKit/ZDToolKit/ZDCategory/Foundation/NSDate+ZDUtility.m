//
//  NSDate+ZDUtility.m
//  Pods
//
//  Created by MOMO on 2017/6/1.
//
//

#import "NSDate+ZDUtility.h"
#import <time.h>

@implementation NSDate (ZDUtility)

+ (NSDate *)zd_dateWithISO8601String:(NSString *)iso8601String {
    time_t t;
    struct tm tm;
    strptime([iso8601String cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
    return date;
}

@end
