//
//  UILabel+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UILabel+ZDUtility.h"
#import <CoreText/CoreText.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UILabel_ZDUtility)

@implementation UILabel (ZDUtility)

- (CGSize)zd_contentSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    
    NSDictionary *attributes = @{NSFontAttributeName : self.font, NSParagraphStyleAttributeName : paragraphStyle};
    
    CGSize contentSize = [self.text boundingRectWithSize:self.frame.size
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:attributes
                                                 context:nil].size;
    return contentSize;
}

// http://stackoverflow.com/questions/34867231/issue-get-lines-array-of-string-inn-label
- (NSArray<NSString *> *)zd_textInLine {
    NSString *text = self.text;
    UIFont *font = self.font;
    CGRect rect = self.frame;
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName
                   value:(__bridge  id)myFont
                   range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, 100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSMutableArray<NSString *> *linesArray = [[NSMutableArray alloc] init];
    for (CFIndex i = 0; i < CFArrayGetCount(lines); ++i) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0]));
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    return [NSArray arrayWithArray:linesArray];
}

#pragma mark - Chain Caller

+ (UILabel *(^)(CGRect frame))zd_initWithFrame {
    return ^UILabel *(CGRect frame) {
        UILabel *label = [[self alloc] initWithFrame:frame];
        return label;
    };
}

- (UILabel *(^)(UIFont *font))zd_font {
    return ^UILabel *(UIFont *font) {
        self.font = font;
        return self;
    };
}

- (UILabel *(^)(CGFloat fontSize))zd_fontSize {
    return ^UILabel *(CGFloat fontSize) {
        self.font = [UIFont systemFontOfSize:fontSize];
        return self;
    };
}

- (UILabel *(^)(CGFloat boldFontSize))zd_boldFontSize {
    return ^UILabel *(CGFloat boldFontSize) {
        self.font = [UIFont boldSystemFontOfSize:boldFontSize];
        return self;
    };
}

- (UILabel *(^)(NSString *))zd_text {
    return ^UILabel *(NSString *text) {
        self.text = text;
        return self;
    };
}

- (UILabel *(^)(UIColor *color))zd_textColor {
    return ^UILabel *(UIColor *color) {
        self.textColor = color;
        return self;
    };
}

- (UILabel *(^)(NSTextAlignment alignment))zd_textAlignment {
    return ^UILabel *(NSTextAlignment alignment) {
        self.textAlignment = alignment;
        return self;
    };
}

- (UILabel *(^)(NSLineBreakMode))zd_lineBreakMode {
    return ^UILabel *(NSLineBreakMode lineBreakMode) {
        self.lineBreakMode = lineBreakMode;
        return self;
    };
}

- (UILabel *(^)(NSInteger))zd_numberOfLines {
    return ^UILabel *(NSInteger lines) {
        self.numberOfLines = lines;
        return self;
    };
}

- (UILabel *(^)(NSAttributedString *))zd_attributedText {
    return ^UILabel *(NSAttributedString *attributedText) {
        self.attributedText = attributedText;
        return self;
    };
}

- (UILabel *(^)(CGFloat))zd_preferredMaxLayoutWidth {
    return ^UILabel *(CGFloat preferMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = preferMaxLayoutWidth;
        return self;
    };
}

@end
