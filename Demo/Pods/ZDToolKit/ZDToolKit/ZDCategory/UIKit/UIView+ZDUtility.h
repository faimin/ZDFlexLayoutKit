//
//  UIView+Utility.h
//  ZDUtility
//
//  Created by Zero on 15/8/4.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZDUtility)

//MARK: Controller
@property (nullable, nonatomic, strong, readonly) UIViewController *zd_viewController;
@property (nullable, nonatomic, strong, readonly) UIViewController *zd_topMostController;

//MARK: Method
- (UIWindow *)zd_normalLevelWindow;
/// Traverse all subviews
- (void)zd_eachSubview:(void (^)(UIView *subview))block;
- (void)zd_removeAllSubviews;
- (BOOL)zd_isSubviewForView:(UIView *)superView; ///< 是不是superView的子视图

/// Create a snapshot image of the complete view hierarchy.
- (UIImage *)zd_snapshotImage;

/// Create a snapshot image of the complete view hierarchy.
/// @discussion It's faster than "snapshotImage", but may cause screen updates.
/// See -[UIView drawViewHierarchyInRect:afterScreenUpdates:] for more information.
- (UIImage *)zd_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

///  Create a snapshot PDF of the complete view hierarchy.
- (nullable NSData *)zd_snapshotPDF;

/// set corner radius for view
- (void)zd_roundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;

///  view shake
///  @param range 角度
- (void)zd_shake:(CGFloat)range;

///  计算添加约束后视图的高度
///  @param maxWidth 最大宽度
///  @return 适应的高度
- (CGFloat)zd_calculateDynamicHeightWithMaxWidth:(CGFloat)maxWidth;

/// load view from xib 
+ (instancetype)zd_loadViewFromXib;

///  add tap && longPress gesture to view
- (void)zd_addTapGestureWithBlock:(void(^)(UITapGestureRecognizer *tapGesture))tapBlock;
- (void)zd_addLongPressGestureWithBlock:(void(^)(UILongPressGestureRecognizer *longPressGesture))longPressBlock;

/// find the contraint
- (nullable NSLayoutConstraint *)zd_constraintForAttribute:(NSLayoutAttribute)attribute;

@end

#pragma mark -
///====================================================================

@interface UIView (Frame)

//MARK: Frame
// Frame
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

// Frame Origin
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

// Frame Size
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

// Frame Borders
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;

// Center Point
#if !IS_IOS_DEVICE
@property (nonatomic) CGPoint center;
#endif
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

// Middle Point, base on the view's bounds
@property (nonatomic, readonly) CGPoint middlePoint;
@property (nonatomic, readonly) CGFloat middleX;
@property (nonatomic, readonly) CGFloat middleY;

// Layer
@property (nonatomic, assign) CGFloat zd_cornerRadius;

/// Extend clickable area, e.g: self.zd_touchExtendInsets = UIEdgeInsetsMake(10, 20, 40, 10);
@property (nonatomic, assign) UIEdgeInsets zd_touchExtendInsets;

/// Chain Caller
- (UIView *(^)(CGFloat))zd_left;
- (UIView *(^)(CGFloat))zd_right;
- (UIView *(^)(CGFloat))zd_top;
- (UIView *(^)(CGFloat))zd_bottom;
- (UIView *(^)(CGFloat))zd_width;
- (UIView *(^)(CGFloat))zd_height;
- (UIView *(^)(CGFloat))zd_centerX;
- (UIView *(^)(CGFloat))zd_centerY;
- (UIView *(^)(CGPoint))zd_center;
- (UIView *(^)(CGPoint))zd_origin;
- (UIView *(^)(CGSize ))zd_size;

@end

NS_ASSUME_NONNULL_END








