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
#define YGDimensionFlexibilityFlexibleWidth (ZDDimensionFlexibilityFlexibleWidth)
#define YGDimensionFlexibilityFlexibleHeight (ZDDimensionFlexibilityFlexibleHeight)

#endif /* ZDFlexLayoutDefine_h */
