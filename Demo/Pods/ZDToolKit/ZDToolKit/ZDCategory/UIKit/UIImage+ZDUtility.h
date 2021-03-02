//
//  UIImage+ZDUtility.h
//  ZDUtility
//
//  Created by Zero on 15/12/26.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZDUtility)

- (BOOL)zd_hasAlphaChannel;
- (UIImage *)zd_addAlphaChannle;
/// 获取图片上某一点的颜色
- (nullable UIColor *)zd_getPixelColorAtLocation:(CGPoint)point;

/// 拉伸图片
- (UIImage *)zd_resizeable;
/// 限制最大边的长度为多少,然后进行等比缩放
- (UIImage *)zd_scaleWithLimitLength:(CGFloat)length;
/// Same as 'scale to fill' in IB.
- (UIImage *)zd_scaleToFillSize:(CGSize)newSize;
/// Preserves aspect ratio. Same as 'aspect fit' in IB.
- (UIImage *)zd_scaleToFitSize:(CGSize)newSize;
- (UIImage *)zd_resizeToSize:(CGSize)newSize;
- (UIImage *)zd_thumbnailWithSize:(CGSize)imageSize;

- (UIImage *)zd_imageByInsetEdge:(UIEdgeInsets)insets
                       withColor:(UIColor *)color;

- (UIImage *)zd_imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)zd_imageByRoundCornerRadius:(CGFloat)radius
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(nullable UIColor *)borderColor;
- (UIImage *)zd_imageByRoundCornerRadius:(CGFloat)radius
                                 corners:(UIRectCorner)corners
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(nullable UIColor *)borderColor
                          borderLineJoin:(CGLineJoin)borderLineJoin;

/// 方向旋转
- (UIImage *)zd_fixOrientation;
- (UIImage *)zd_imageByRotate:(CGFloat)radians
                   fitSize:(BOOL)fitSize;

/// 根据bundle中的文件名读取图片,返回无缓存的图片
+ (UIImage *)zd_imageWithFileName:(NSString *)name;
+ (UIImage *)zd_imageWithColor:(UIColor *)color;

/// 在图片上绘制文字
- (UIImage *)zd_imageWithTitle:(NSString *)title
                      fontSize:(CGFloat)fontSize;

@end

NS_ASSUME_NONNULL_END
