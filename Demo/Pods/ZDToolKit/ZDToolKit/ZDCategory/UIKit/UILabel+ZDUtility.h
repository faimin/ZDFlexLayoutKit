//
//  UILabel+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (ZDUtility)

- (CGSize)zd_contentSize;

/// text in every line
- (NSArray<NSString *> *)zd_textInLine;

/// chain caller
+ (UILabel *(^)(CGRect))zd_initWithFrame;
- (UILabel *(^)(UIFont *))zd_font;
- (UILabel *(^)(CGFloat))zd_fontSize;
- (UILabel *(^)(CGFloat))zd_boldFontSize;
- (UILabel *(^)(NSString *))zd_text;
- (UILabel *(^)(UIColor *))zd_textColor;
- (UILabel *(^)(NSInteger))zd_numberOfLines;
- (UILabel *(^)(NSTextAlignment))zd_textAlignment;
- (UILabel *(^)(NSLineBreakMode))zd_lineBreakMode;
- (UILabel *(^)(NSAttributedString *))zd_attributedText;
- (UILabel *(^)(CGFloat))zd_preferredMaxLayoutWidth;

@end

NS_ASSUME_NONNULL_END
