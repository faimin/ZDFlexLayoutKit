//
//  UIView+Utility.m
//  ZDUtility
//
//  Created by Zero on 15/8/4.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "UIView+ZDUtility.h"
#import <objc/runtime.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UIView_ZDUtility)

static const void *TouchExtendInsetKey = &TouchExtendInsetKey;
static const void *CornerRadiusKey = &CornerRadiusKey;
static const void *TapGestureKey = &TapGestureKey;
static const void *TapGestureBlockKey = &TapGestureBlockKey;
static const void *LongPressGestureKey = &LongPressGestureKey;
static const void *LongPressGestureBlockKey = &LongPressGestureBlockKey;

static void __Swizzle__(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@implementation UIView (ZDUtility)

#pragma mark Controller

- (UIViewController *)zd_viewController {
	UIResponder *nextResponder = self;

	do {
		nextResponder = [nextResponder nextResponder];

		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController *)nextResponder;
		}
	} while (nextResponder != nil);

	return nil;
}

- (UIViewController *)zd_topMostController {
	NSMutableArray *controllersHierarchy = [[NSMutableArray alloc] init];
	UIViewController *topController = self.window.rootViewController;

	if (topController) {
		[controllersHierarchy addObject:topController];
	}

	while ([topController presentedViewController]) {
		topController = [topController presentedViewController];
		[controllersHierarchy addObject:topController];
	}

	UIResponder *matchController = self.zd_viewController;

	while (matchController != nil && [controllersHierarchy containsObject:matchController] == NO) {
		do {
			matchController = [matchController nextResponder];
		} while (matchController != nil && ![matchController isKindOfClass:[UIViewController class]]);
	}

	return (UIViewController *)matchController;
}

#pragma mark Method

- (UIWindow *)zd_normalLevelWindow {
    UIWindow *targetWindow = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (targetWindow.windowLevel != UIWindowLevelNormal) {
        NSEnumerator<UIWindow *> *windows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];
        for (UIWindow *tempWindow in windows) {
            if (tempWindow.windowLevel == UIWindowLevelNormal) {
                targetWindow = tempWindow;
                break;
            }
        }
    }
    return targetWindow;
}

- (void)zd_eachSubview:(void (^)(UIView *subview))block {
	NSParameterAssert(block != nil);
	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		block(subview);
	}];
}

- (void)zd_removeAllSubviews {
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

- (BOOL)zd_isSubviewForView:(UIView *)superView {
    BOOL isSubview = ([self isDescendantOfView:superView] && ![self isEqual:superView]);
    return isSubview;
}

- (UIImage *)zd_snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)zd_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    UIImage *screenshotImage = nil;
    if (@available(iOS 7.0, *)) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        screenshotImage = [self zd_snapshotImage];
    }
    return screenshotImage;
}

- (NSData *)zd_snapshotPDF {
    CGRect bounds = self.bounds;
    NSMutableData* data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (void)zd_roundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    CGRect frame = self.bounds;
    // NSAssert(!CGRectIsEmpty(frame), @"宽和高不能为0");
    if (CGRectIsEmpty(frame)) return;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                   byRoundingCorners:corners
                                                         cornerRadii:(CGSize){radius, radius}];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

- (void)zd_shake:(CGFloat)range {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    animation.values = @[@(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0)];
    animation.repeatCount = CGFLOAT_MAX;
    [self.layer addAnimation:animation forKey:@"shake"];
}

/// Inspiration from ‘UITableView+FDTemplateLayoutCell’
- (CGFloat)zd_calculateDynamicHeightWithMaxWidth:(CGFloat)maxWidth {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat viewMaxWidth = maxWidth ? : CGRectGetWidth([UIScreen mainScreen].bounds);
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:viewMaxWidth];
    
    [self addConstraint:widthConstraint];
    CGSize fittingSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self removeConstraint:widthConstraint];
    
    return fittingSize.height;
}

+ (instancetype)zd_loadViewFromXib {
    NSString *className = NSStringFromClass(self);
    NSString *xibPatch =  [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.nib", className] ofType:nil];
    if (xibPatch) {
        return [[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil].firstObject;
    }
    NSLog(@"\n\n不存在调用者class类型的xib文件\n");
    return nil;
}

#pragma mark Gesture

- (void)zd_addTapGestureWithBlock:(void(^)(UITapGestureRecognizer *tapGesture))tapBlock {
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, TapGestureKey);
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zd_handleTapAction:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        objc_setAssociatedObject(self, TapGestureKey, tap, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(tap, TapGestureBlockKey, tapBlock, OBJC_ASSOCIATION_COPY);
}

- (void)zd_addLongPressGestureWithBlock:(void(^)(UILongPressGestureRecognizer *longPressGesture))longPressBlock {
    UILongPressGestureRecognizer *longPress = objc_getAssociatedObject(self, LongPressGestureKey);
    if (!longPress) {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(zd_handleLongPressAction:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:longPress];
        objc_setAssociatedObject(self, LongPressGestureKey, longPress, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(longPress, LongPressGestureBlockKey, longPressBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark Private Method

- (void)zd_handleTapAction:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        void(^tapActionBlock)(UITapGestureRecognizer *) = objc_getAssociatedObject(tapGesture, TapGestureBlockKey);
        if (tapActionBlock) {
            tapActionBlock(tapGesture);
        }
    }
}

- (void)zd_handleLongPressAction:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateRecognized) {
        void(^longPressActionBlock)(UILongPressGestureRecognizer *) = objc_getAssociatedObject(longPressGesture, LongPressGestureBlockKey);
        if (longPressActionBlock) {
            longPressActionBlock(longPressGesture);
        }
    }
}

#pragma mark - Constraints

- (NSLayoutConstraint *)zd_constraintForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d && (firstItem = %@ || secondItem = %@)", attribute, self, self];
    NSArray *constraintArray = [self.superview constraints];
    
    if (attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight) {
        constraintArray = [self constraints];
    }
    
    NSArray *fillteredArray = [constraintArray filteredArrayUsingPredicate:predicate];
    return fillteredArray.firstObject;
}

@end

#pragma mark -
///========================================================

@implementation UIView (Frame)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __Swizzle__(self, @selector(pointInside:withEvent:), @selector(zdPointInside:withEvent:));
    });
}

#pragma mark Frame

- (CGPoint)origin {
	return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin {
	CGRect newFrame = self.frame;

	newFrame.origin = newOrigin;
	self.frame = newFrame;
}

- (CGSize)size {
	return self.frame.size;
}

- (void)setSize:(CGSize)newSize {
	CGRect newFrame = self.frame;

	newFrame.size = newSize;
	self.frame = newFrame;
}

#pragma mark Frame Origin

- (CGFloat)x {
	return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX {
	CGRect newFrame = self.frame;

	newFrame.origin.x = newX;
	self.frame = newFrame;
}

- (CGFloat)y {
	return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY {
	CGRect newFrame = self.frame;

	newFrame.origin.y = newY;
	self.frame = newFrame;
}

#pragma mark Frame Size

- (CGFloat)height {
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
	CGRect newFrame = self.frame;

	newFrame.size.height = newHeight;
	self.frame = newFrame;
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
	CGRect newFrame = self.frame;

	newFrame.size.width = newWidth;
	self.frame = newFrame;
}

#pragma mark Frame Borders

- (CGFloat)left {
	return self.x;
}

- (void)setLeft:(CGFloat)left {
	self.x = left;
}

- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
	self.x = right - self.width;
}

- (CGFloat)top {
	return self.y;
}

- (void)setTop:(CGFloat)top {
	self.y = top;
}

- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
	self.y = bottom - self.height;
}

#pragma mark Center Point

#if !IS_IOS_DEVICE
- (CGPoint)center {
	return CGPointMake(self.left + self.middleX, self.top + self.middleY);
}

- (void)setCenter:(CGPoint)newCenter {
	self.left = newCenter.x - self.middleX;
	self.top = newCenter.y - self.middleY;
}
#endif

- (CGFloat)centerX {
	return self.center.x;
}

- (void)setCenterX:(CGFloat)newCenterX {
	self.center = CGPointMake(newCenterX, self.center.y);
}

- (CGFloat)centerY {
	return self.center.y;
}

- (void)setCenterY:(CGFloat)newCenterY {
	self.center = CGPointMake(self.center.x, newCenterY);
}

#pragma mark Middle Point

- (CGPoint)middlePoint {
	return CGPointMake(self.middleX, self.middleY);
}

- (CGFloat)middleX {
	return self.width * 0.5;
}

- (CGFloat)middleY {
	return self.height * 0.5;
}

#pragma mark - Chain Caller

- (UIView *(^)(CGFloat))zd_left {
    return ^UIView *(CGFloat left) {
        CGRect frame = self.frame;
        frame.origin.x = left;
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_right {
    return ^UIView *(CGFloat right) {
        CGRect frame = self.frame;
        frame.origin.x = right - CGRectGetWidth(frame);
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_top {
    return ^UIView *(CGFloat top) {
        CGRect frame = self.frame;
        frame.origin.y = top;
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_bottom {
    return ^UIView *(CGFloat bottom) {
        CGRect frame = self.frame;
        frame.origin.y = bottom - CGRectGetHeight(frame);
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_width {
    return ^UIView *(CGFloat width) {
        CGRect frame = self.frame;
        frame.size.width = width;
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_height {
    return ^UIView *(CGFloat height) {
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_centerX {
    return ^UIView *(CGFloat centerX) {
        CGPoint center = self.center;
        center.x = centerX;
        self.center = center;
        return self;
    };
}

- (UIView *(^)(CGFloat))zd_centerY {
    return ^UIView *(CGFloat centerY) {
        CGPoint center = self.center;
        center.y = centerY;
        self.center = center;
        return self;
    };
}

- (UIView *(^)(CGPoint))zd_center {
    return ^UIView *(CGPoint center) {
        self.center = center;
        return self;
    };
}

- (UIView *(^)(CGPoint))zd_origin {
    return ^UIView *(CGPoint origin) {
        CGRect frame = self.frame;
        frame.origin = origin;
        self.frame = frame;
        return self;
    };
}

- (UIView *(^)(CGSize))zd_size {
    return ^UIView *(CGSize size) {
        CGRect frame = self.frame;
        frame.size = size;
        self.frame = frame;
        return self;
    };
}

#pragma mark - Layer

- (void)setZd_cornerRadius:(CGFloat)zd_cornerRadius {
    objc_setAssociatedObject(self, CornerRadiusKey, @(zd_cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //下面的方法只有获取到真实的bounds才有效
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:zd_cornerRadius];
    [maskPath addClip];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

- (CGFloat)zd_cornerRadius {
    return [objc_getAssociatedObject(self, CornerRadiusKey) floatValue];
}

#pragma mark - TouchExtendInset

- (BOOL)zdPointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.zd_touchExtendInsets, UIEdgeInsetsZero) || self.hidden) {
        return [self zdPointInside:point withEvent:event];
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.zd_touchExtendInsets);
    hitFrame.size.width = MAX(hitFrame.size.width, 0);
    hitFrame.size.height = MAX(hitFrame.size.height, 0);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)setZd_touchExtendInsets:(UIEdgeInsets)zd_touchExtendInsets {
    UIEdgeInsets zdTouchExtendInsets = UIEdgeInsetsMake(-zd_touchExtendInsets.top, -zd_touchExtendInsets.left, -zd_touchExtendInsets.bottom, -zd_touchExtendInsets.right);
    objc_setAssociatedObject(self, TouchExtendInsetKey, [NSValue valueWithUIEdgeInsets:zdTouchExtendInsets], OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)zd_touchExtendInsets {
    return [objc_getAssociatedObject(self, TouchExtendInsetKey) UIEdgeInsetsValue];
}

@end


@implementation UIImage (CornerRadius)

- (UIImage *)imageWithCornerRadius:(CGFloat)radius {
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        //clip image
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, radius);
        CGContextAddLineToPoint(context, 0.0f, self.size.height - radius);
        CGContextAddArc(context, radius, self.size.height - radius, radius, M_PI, M_PI / 2.0f, 1);
        CGContextAddLineToPoint(context, self.size.width - radius, self.size.height);
        CGContextAddArc(context, self.size.width - radius, self.size.height - radius, radius, M_PI / 2.0f, 0.0f, 1);
        CGContextAddLineToPoint(context, self.size.width, radius);
        CGContextAddArc(context, self.size.width - radius, radius, radius, 0.0f, -M_PI / 2.0f, 1);
        CGContextAddLineToPoint(context, radius, 0.0f);
        CGContextAddArc(context, radius, radius, radius, -M_PI / 2.0f, M_PI, 1);
        CGContextClip(context);
    }
    
    //draw image
    [self drawAtPoint:CGPointZero];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

@end

/**
 
 - (UIImage *)drawImageWithBorderWidth:(CGFloat)borderWidth
 radius:(CGFloat)radius
 borderColor:(UIColor *)borderColor
 backgroundColor:(UIColor *)backgroundColor
 {
 CGFloat halfBorderWidth = borderWidth / 2.0;
 
 UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 CGContextSetLineWidth(context, borderWidth);
 CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
 CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
 
 CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
 CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth);  // 开始坐标右边开始
 CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius);  // 右下角角度
 CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius); // 左下角角度
 CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius); // 左上角
 CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius); // 右上角
 
 CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
 UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return output;
 }

 */
