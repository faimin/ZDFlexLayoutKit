//
//  ZDTextView.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/6/17.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDTextView.h"
#import <Foundation/Foundation.h>

@interface ZDTextView ()
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation ZDTextView

#pragma mark - Life Cycle
- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self zd_configure];
}

- (instancetype)init {
    if (self = [super init]) {
        [self zd_configure];
    }
    return self;
}

- (void)zd_configure {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zd_didChangeText:) name:UITextViewTextDidChangeNotification object:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - Override
- (void)layoutSubviews {
    [super layoutSubviews];
    [self zd_placeholderLabelHidden];
    if (!self.placeholderLabel.hidden) {
        [UIView performWithoutAnimation: ^{
            CGRect bounds = self.bounds;
            //bounds.size.width -= 5;
            self.placeholderLabel.frame = [self zd_placeholderRectThatFits:bounds];
            [self sendSubviewToBack:self.placeholderLabel];
        }];
    }
}

#pragma mark - Public Method
- (NSUInteger)numberOfLines {
    return fabs( (self.contentSize.height - self.contentInset.top - self.contentInset.bottom) / self.font.lineHeight );
}

- (void)removeExtraSpaces {
    self.textContainer.lineFragmentPadding = 0;
    self.textContainerInset = UIEdgeInsetsZero;
}

#pragma mark - Private Method
- (void)zd_didChangeText:(NSNotification *)notification {
    if (![notification.object isEqual:self]) return;
    [self zd_placeholderLabelHidden];
}

- (void)zd_placeholderLabelHidden {
    self.placeholderLabel.hidden = ((self.placeholder.length == 0 && self.attributedPlaceholder.length == 0) || self.text.length > 0);
}

- (CGRect)zd_placeholderRectThatFits:(CGRect)bounds {
    CGRect rect = CGRectZero;
    
    rect.size = [self.placeholderLabel sizeThatFits:bounds.size];
    rect.origin = UIEdgeInsetsInsetRect(bounds, self.textContainerInset).origin;
    CGFloat padding = self.textContainer.lineFragmentPadding;
    rect.origin.x += padding;
    
    return rect;
}

#pragma mark - Property
- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    if (_placeholderTextColor != placeholderTextColor) {
        _placeholderTextColor = placeholderTextColor;
        self.placeholderLabel.textColor = placeholderTextColor;
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    if (![_placeholder isEqualToString:placeholder]) {
        _placeholder = placeholder.copy;
        self.placeholderLabel.text = _placeholder;
    }
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    if (![_attributedPlaceholder isEqualToAttributedString:attributedPlaceholder]) {
        _attributedPlaceholder = attributedPlaceholder.copy;
        self.placeholderLabel.attributedText = _attributedPlaceholder;
    }
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel                     = [[UILabel alloc] init];
        _placeholderLabel.clipsToBounds       = NO;
        _placeholderLabel.autoresizesSubviews = NO;
        //_placeholderLabel.numberOfLines       = 1;
        _placeholderLabel.font                = self.font;
        _placeholderLabel.backgroundColor     = [UIColor clearColor];
        _placeholderLabel.textColor           = [UIColor lightGrayColor];
        _placeholderLabel.hidden              = YES;
        
        [self addSubview:_placeholderLabel];
    }
    return _placeholderLabel;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        UITextView *textView = object;
        textView.frame = (CGRect){textView.frame.origin, CGRectGetWidth(textView.frame), textView.contentSize.height};
        CGFloat topCorrect = (CGRectGetHeight(textView.bounds) - textView.contentSize.height * textView.zoomScale) / 2.0f;
        topCorrect = MAX(0.0, topCorrect);
        textView.contentOffset = (CGPoint){0, -topCorrect};
    }
}

@end
