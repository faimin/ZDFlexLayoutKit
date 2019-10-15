//
//  UIColor+ZDUtility.h
//  ZDUtility
//
//  Created by Zero on 16/1/5.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ZDUtility)

/// 获取UIColor对象的CMYK字符串值。
@property (nonatomic, copy, readonly) NSString *zd_CMYKString;

- (NSDictionary<NSString *, NSNumber *> *)zd_RGBDictionary;

/// 随机色
+ (UIColor *)zd_randomColor;

+ (UIColor *)zd_colorWithRGBA:(uint32_t)rgbaValue;

+ (UIColor *)zd_colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

- (NSString *)zd_hexString;

- (NSString *)zd_rgbStringValueWithAlpha:(BOOL)alpha;

- (BOOL)zd_isEqualToColor:(UIColor *)otherColor;

@end

NS_ASSUME_NONNULL_END






