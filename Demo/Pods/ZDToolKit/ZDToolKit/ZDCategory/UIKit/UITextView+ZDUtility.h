//
//  UITextView+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (ZDUtility)

/// 利用KVC替换textView隐藏的label属性
@property (nonatomic, strong) UILabel *zd_placeHolderLabel;

/// 限制最大输入字数为maxLength
- (NSUInteger)letterCountWithMaxLength:(NSUInteger)maxLength;

/// 在textView上添加一个可响应事件的view
- (void)addButton:(UIControl *)button;

@end

NS_ASSUME_NONNULL_END
