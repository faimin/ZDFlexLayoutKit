//
//  ZDFlexLayoutDefine.h
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2020/12/1.
//

#ifndef ZDFlexLayoutDefine_h
#define ZDFlexLayoutDefine_h

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, ZDDimensionFlexibility) {
    ZDDimensionFlexibilityFlexibleNone      = 0,
    ZDDimensionFlexibilityFlexibleWidth     = 1 << 0,
    ZDDimensionFlexibilityFlexibleHeight    = 1 << 1,
    ZDDimensionFlexibilityFlexibleAll       = ~0L
};

// compatible with older versions
#define YGDimensionFlexibility ZDDimensionFlexibility
#define YGDimensionFlexibilityFlexibleNone (ZDDimensionFlexibilityFlexibleNone)
#define YGDimensionFlexibilityFlexibleWidth (ZDDimensionFlexibilityFlexibleWidth)
#define YGDimensionFlexibilityFlexibleHeight (ZDDimensionFlexibilityFlexibleHeight)
#define YGDimensionFlexibilityFlexibleAll (ZDDimensionFlexibilityFlexibleAll)

/// Async execution mode for layout calculation
typedef NS_ENUM(NSInteger, ZDFlexLayoutAsyncMode) {
    /// Calculate and apply layout synchronously on the calling thread.
    ZDFlexLayoutAsyncModeSync = 0,
    /// Defer layout calculation to the main runloop idle time.
    ZDFlexLayoutAsyncModeRunloopIdle,
    /// Calculate layout on a background thread, then apply frames on the main thread.
    ZDFlexLayoutAsyncModeBackgroundThread,
};

#endif /* ZDFlexLayoutDefine_h */
