//
//  NSMutableArray+ZDUtility.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/4.
//
//

#import "NSMutableArray+ZDUtility.h"

@implementation NSMutableArray (ZDUtility)

+ (id)zd_mutableArrayUsingWeakReferences {
    return [self zd_mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)zd_mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // Cast of C pointer type 'CFMutableArrayRef' (aka 'struct __CFArray *') to Objective-C pointer type 'id' requires a bridged cast
    return (id)CFBridgingRelease(CFArrayCreateMutable(0, capacity, &callbacks));
}

@end

