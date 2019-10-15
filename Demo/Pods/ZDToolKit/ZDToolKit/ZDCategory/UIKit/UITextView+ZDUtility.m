//
//  UITextView+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UITextView+ZDUtility.h"
#import <objc/runtime.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UITextView_ZDUtility)

static const void *PlaceHolderLabelKey = &PlaceHolderLabelKey;

@implementation UITextView (ZDUtility)

- (NSUInteger)letterCountWithMaxLength:(NSUInteger)maxLength {
    NSString *toBeString = self.text;
    NSUInteger txtCount = toBeString.length;
    
    UITextRange *selectedRange = [self markedTextRange];
    //获取高亮部分
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > maxLength) {
            self.text = [toBeString substringToIndex:maxLength];
        }
    }
    // 有高亮选择的字符串，去掉高亮的字数
    else {
        NSInteger startOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        // 去掉高亮的字数
        txtCount -= offsetRange.length;
    }
    
    // 超出部分警告和限制
    if (txtCount > maxLength) {
        self.text = [toBeString substringToIndex:maxLength];
        return maxLength;
    }
    return txtCount;
}

- (void)setZd_placeHolderLabel:(UILabel *)zd_placeHolderLabel {
    if (!zd_placeHolderLabel) {
        return;
    }
    [self addSubview:zd_placeHolderLabel];
    [self setValue:zd_placeHolderLabel forKey:@"_placeholderLabel"];
    objc_setAssociatedObject(self, PlaceHolderLabelKey, zd_placeHolderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)zd_placeHolderLabel {
    return objc_getAssociatedObject(self, PlaceHolderLabelKey);
}

// http://www.tuicool.com/articles/IBFbMfn
- (void)addButton:(UIControl *)button {
    NSMutableAttributedString *mutAttri = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    // 注意：占位符不能用数字
    NSAttributedString *placeholderAttri = [[NSAttributedString alloc] initWithString:@"EEE" attributes:@{NSForegroundColorAttributeName : [UIColor clearColor]}];
    [mutAttri appendAttributedString:placeholderAttri];
    self.attributedText = mutAttri;
    
    // 计算textView文本时，计算宽度需要比textView本身的宽度减少8
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    CGFloat height = [mutAttri boundingRectWithSize:CGSizeMake(selfWidth - 8, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    // textView高度必须比文字高度多2 * 8的额外高度
    self.frame = (CGRect){CGPointZero, selfWidth, height+16};
    
    self.selectedRange = NSMakeRange(self.text.length - 2, 2);
    NSArray *textSelectionRects = [self selectionRectsForRange:self.selectedTextRange];
    for (UITextSelectionRect *selectionRect in textSelectionRects) {
        CGRect frame = selectionRect.rect;
        // 改变button的frame
        button.frame = frame;
        [self addSubview:button];
    }
}

@end
