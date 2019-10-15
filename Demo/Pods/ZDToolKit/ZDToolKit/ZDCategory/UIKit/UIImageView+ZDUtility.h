//
//  UIImageView+ZDUtility.h
//  ZDUtility
//
//  Created by Zero on 16/1/13.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (ZDUtility)

/// 此方法执行的前提是image必须提前设置好
- (void)zd_roundedImageWithCornerRadius:(CGFloat)cornerRadius
                             completion:(void (^)(UIImage *image))completion;

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
/// radius传CGFLOAT_MIN，就是默认以视图宽度的一半为圆角
- (void)zd_setImageWithURL:(NSString *)urlStr
          placeholderImage:(nullable NSString *)placeHolderStr
              cornerRadius:(CGFloat)radius;
#endif

@end

NS_ASSUME_NONNULL_END
