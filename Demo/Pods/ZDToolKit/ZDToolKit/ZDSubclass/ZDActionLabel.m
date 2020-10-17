//
//  ZDLabel.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDActionLabel.h"
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDActionLabel ()
{
//    CGFloat _iLineSpacing;
//    CALayer *_underlindeLayer;
//    CGRect _textRect;
//    NSMutableDictionary *_targetActions;
//    CTFrameRef _ctFrameRef;
}
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic, strong) NSArray *params;
@property (nonatomic, strong) NSArray<NSValue *> *ranges;
@end

@implementation ZDActionLabel

#pragma mark - TextKit
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textContainer.size = self.bounds.size;
}

#pragma mark - add links
- (void)setup {
    //[self prepareText];
    
    self.textStorage = [[NSTextStorage alloc] init];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] init];
    
    // 以下基本是固定写法
    // 先将布局添加到 storeage 中,然后再将容器添加到布局中
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
    
    self.userInteractionEnabled = YES;
    
    // 文字到左端的距离,默认是5.0
    self.textContainer.lineFragmentPadding = 0.0;
}

- (void)setText:(nullable NSString *)text {
    [super setText:text];
    [self prepareText];
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self prepareText];
}

- (void)prepareText {
    NSAttributedString *attribuString = nil;
    if (self.attributedText) {
        attribuString = self.attributedText;
    }
    else if (self.text) {
        attribuString = [[NSAttributedString alloc] initWithString:self.text];
    }
    else {
        attribuString = [[NSAttributedString alloc] initWithString:@""];
    }
    
    // 设置格式
    NSMutableAttributedString *mutiAttributeString = [self configAttribuText:attribuString];
    
    // 设置storage内容
    [self.textStorage setAttributedString:mutiAttributeString];
    
    [self setNeedsDisplay];
}

- (NSMutableAttributedString *)configAttribuText:(NSAttributedString *)attrString {
    NSMutableAttributedString *mutiAttriString = attrString.mutableCopy;
    if (mutiAttriString.length == 0) return mutiAttriString;
    
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *attributeDic = [mutiAttriString attributesAtIndex:0 effectiveRange:&range].mutableCopy;
    NSMutableParagraphStyle *paragraphStyle = [attributeDic[NSParagraphStyleAttributeName] mutableCopy];
    
    if (paragraphStyle) {
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else {
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        attributeDic[NSParagraphStyleAttributeName] = paragraphStyle;
        [mutiAttriString setAttributes:attributeDic range:range];
    }
    
    return mutiAttriString;
}

/// 如果想让正则表达式来检测,则用下面的两个方法
- (NSArray *)getLinkRanges {
    NSError *__autoreleasing error;
    NSDataDetector *regex = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error]; // 正则表达式
    NSArray *results = [self getRangesFromRegularExpression:regex];
    return results;
}

- (NSArray<NSValue *> *)getRangesFromRegularExpression:(__kindof NSRegularExpression *)regex {
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:self.textStorage.string options:NSMatchingReportProgress range:NSMakeRange(0, self.textStorage.length)];
    
    NSMutableArray *ranges = [[NSMutableArray  alloc] init];
    for (NSTextCheckingResult *result in results) {
        NSRange range = result.range;
        NSValue *value = [NSValue value:&range withObjCType:@encode(NSRange)];
        [ranges addObject:value];
    }
    return ranges;
}

- (void)addTarget:(id)target
           action:(SEL)action
           params:(nullable NSArray *)params
           ranges:(NSArray<NSValue *> *)ranges {
    if (!target || NULL == action) return;
    
    __unused NSUInteger paramsCount = MAX([NSStringFromSelector(action) componentsSeparatedByString:@":"].count - 1, 0);
    NSCAssert(paramsCount == params.count, @"参数个数不符");
    self.invocation = ({
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invocation setTarget:target];
        [invocation setSelector:action];
        [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [invocation setArgument:&obj atIndex:idx + 2];
        }];
        [invocation retainArguments];
        invocation;
    });
    self.ranges = ranges;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //获取点击字符的索引位置
    NSUInteger index = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer];
    for (NSValue *rangeValue in self.ranges) {
        NSRange range = rangeValue.rangeValue;
        // 索引是否在要响应的range里
        BOOL isInRange = NSLocationInRange(index, range);
        if (isInRange) {
            [self.invocation invoke];
            //( (void (*)(id, SEL))(void *) objc_msgSend)(self.target, self->_selector);
            break;
        }
    }
}

// 绘制文本
- (void)drawTextInRect:(CGRect)rect {
    // textKit重绘文字
    NSRange range = NSMakeRange(0, self.textStorage.length);
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}

@end

NS_ASSUME_NONNULL_END


#if 0
 /// CoreText实现图文混排之点击事件：http://www.jianshu.com/p/51c47329203e
- (void)setTarget:(id)target action:(SEL)selector forRange:(NSRange)range
{
    if (nil == target || NULL == selector) {
        return;
    }
    
    NSValue *value = [NSValue valueWithRange:range];
    if (nil == _targetActions) {
        _targetActions = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    NSDictionary *targetActionDict = [_targetActions objectForKey:value];
    if (targetActionDict) {
        [targetActionDict setValue:target forKey:@"target"];
        [targetActionDict setValue:NSStringFromSelector(selector) forKey:@"action"];
    }
    else{
        targetActionDict = @{@"target":target,@"action":NSStringFromSelector(selector)};
        [_targetActions setObject:targetActionDict forKey:value];
    }
}

- (NSInteger)indexOfTouchLocation:(CGPoint)location
{
    if (NULL == _ctFrameRef) {
        NSAttributedString *content = self.attributedText;
        CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((__bridge_retained CFAttributedStringRef)content);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, _textRect);
        //创建CTFrame
        _ctFrameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, content.length), path, NULL);
        CFRelease(framesetter);
        CGPathRelease(path);
    }
    
    CFArrayRef lines = CTFrameGetLines(_ctFrameRef);
    CGPoint origins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_ctFrameRef, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    CGPathRef path = CTFrameGetPath(_ctFrameRef);
    CGRect rect = CGPathGetBoundingBox(path);
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CGPoint origin = origins[i];
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        if ((location.y >= y - _iLineSpacing/2.0f)
            && (location.y <= y + self.font.lineHeight + _iLineSpacing/2.0f)
            && (location.x >= origin.x)) {
            
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    
    location.x -= lineOrigin.x;
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    return index;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    NSInteger index = [self indexOfTouchLocation:location];
    if (index != NSNotFound) {
        NSDictionary *targetAction = nil;
        NSArray *targetActionsKeys = [_targetActions allKeys];
        for (NSValue *value in targetActionsKeys) {
            NSRange range = [value rangeValue];
            if (range.location < index && index < range.location + range.length) {
                targetAction = [_targetActions objectForKey:value];
                break;
            }
        }
        
        if (targetAction) {
            id target = [targetAction objectForKey:@"target"];
            SEL selector = NSSelectorFromString([targetAction objectForKey:@"action"]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }
}
#endif

