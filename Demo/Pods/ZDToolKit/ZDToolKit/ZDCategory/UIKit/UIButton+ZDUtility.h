//
//  UIButton+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/1/29.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//  https://github.com/Phelthas/Demo_ButtonImageTitleEdgeInsets
//  http://www.tuicool.com/articles/byaMbaa

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZDImagePosition) {
    ZDImagePosition_Left = 0,
    ZDImagePosition_Right,
    ZDImagePosition_Top,
    ZDImagePosition_Bottom
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ZDUtility)

/// @brief 排列button中的image和title
/// @param spacing 图片和文字的间隔
/// @param insets 文字内边距
/// @param extraAttributesBlock 设置计算label高度时需要的属性参数
- (void)zd_imagePosition:(ZDImagePosition)postion spacing:(CGFloat)spacing contentInsets:(UIEdgeInsets)insets extraAttributes:(void(^_Nullable)(NSMutableDictionary *attributes))extraAttributesBlock;
- (void)zd_imagePosition:(ZDImagePosition)postion spacing:(CGFloat)spacing;

- (void)zd_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
