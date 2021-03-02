//
//  UIColor+ZDUtility.m
//  ZDUtility
//
//  Created by Zero on 16/1/5.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIColor+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UIColor_ZDUtility)

@implementation UIColor (ZDUtility)

///  获取UIColor对象的CMYK字符串值。
///
///  @return CMYK字符串
- (NSString *)zd_CMYKString {
	// Method provided by the Colours class extension
	NSDictionary *cmykDict = [self zd_getCMYKValueByColor:self];
	return [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f, %0.2f)",
		   [cmykDict[@"C"] floatValue],
		   [cmykDict[@"M"] floatValue],
		   [cmykDict[@"Y"] floatValue],
		   [cmykDict[@"K"] floatValue]
    ];
}

///  获取UIColor对象的CMYK值。
///
///  @param originColor 原始颜色
///  @return CMYK的字典
- (NSDictionary<NSString *, NSNumber *> *)zd_getCMYKValueByColor:(UIColor *)originColor {
	// Convert RGB to CMY
	NSDictionary *rgb = [self zd_RGBDictionary];
	CGFloat C = 1 - [rgb[@"R"] floatValue];
	CGFloat M = 1 - [rgb[@"G"] floatValue];
	CGFloat Y = 1 - [rgb[@"B"] floatValue];

	// Find K
	CGFloat K = MIN(1, MIN(C, MIN(Y, M)));

	if (K == 1) {
		C = 0;
		M = 0;
		Y = 0;
	}
	else {
		void (^newCMYK)(CGFloat *);
		newCMYK = ^(CGFloat *x) {
			*x = (*x - K) / (1 - K);
		};
		newCMYK(&C);
		newCMYK(&M);
		newCMYK(&Y);
	}

	return @{
        @"C" : @(C),
        @"M" : @(M),
        @"Y" : @(Y),
        @"K" : @(K)
    };
}

///  获取UIColor对象的RGB值。
///
///  @return 包含rgb值的字典对象。
- (NSDictionary<NSString *, NSNumber *> *)zd_RGBDictionary {
	CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;

	if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
		[self getRed:&r green:&g blue:&b alpha:&a];
	}
	else {
		const CGFloat *components = CGColorGetComponents(self.CGColor);
		r = components[0];
		g = components[1];
		b = components[2];
		a = components[3];
	}

	return @{
        @"R" : @(r),
        @"G" : @(g),
        @"B" : @(b),
        @"A" : @(a)
    };
}

+ (UIColor *)zd_randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

+ (UIColor *)zd_colorWithRGBA:(uint32_t)rgbaValue {
    return [UIColor colorWithRed:((rgbaValue & 0xFF000000) >> 24) / 255.0f
                           green:((rgbaValue & 0xFF0000) >> 16) / 255.0f
                            blue:((rgbaValue & 0xFF00) >> 8) / 255.0f
                           alpha:(rgbaValue & 0xFF) / 255.0f];
}

+ (UIColor *)zd_colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:alpha];
}

- (NSString *)zd_hexString {
    return [self zd_rgbStringValueWithAlpha:NO];
}

- (NSString *)zd_rgbStringValueWithAlpha:(BOOL)alpha {
    CGColorRef color = self.CGColor;
    size_t count = CGColorGetNumberOfComponents(color);
    const CGFloat *components = CGColorGetComponents(color);
    static NSString *stringFormat = @"%02x%02x%02x";
    NSString *hex = nil;
    if (count == 2) {
        NSUInteger white = (NSUInteger)(components[0] * 255.0f);
        hex = [NSString stringWithFormat:stringFormat, white, white, white];
    } else if (count == 4) {
        hex = [NSString stringWithFormat:stringFormat,
               (NSUInteger)(components[0] * 255.0f),
               (NSUInteger)(components[1] * 255.0f),
               (NSUInteger)(components[2] * 255.0f)];
    }
    
    if (hex && alpha) {
        hex = [hex stringByAppendingFormat:@"%02lx",
               (unsigned long)(CGColorGetAlpha(self.CGColor) * 255.0 + 0.5)];
    }
    return hex;
}

- (BOOL)zd_isEqualToColor:(UIColor *)otherColor {
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate( colorSpaceRGB, components );
            
            UIColor *color = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            return color;
        } else {
            return color;
        }
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}

@end
