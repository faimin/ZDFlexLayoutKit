//
//  NSMutableArray+ZDUtility.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/4.
//
//

#import "NSMutableArray+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSMutableArray_ZDUtility)

@implementation NSMutableArray (ZDUtility)

+ (instancetype)zd_mutableArrayUsingWeakReferences {
    return [self zd_mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (instancetype)zd_mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // Cast of C pointer type 'CFMutableArrayRef' (aka 'struct __CFArray *') to Objective-C pointer type 'id' requires a bridged cast
    return (NSMutableArray *)CFBridgingRelease(CFArrayCreateMutable(0, capacity, &callbacks));
}

@end

