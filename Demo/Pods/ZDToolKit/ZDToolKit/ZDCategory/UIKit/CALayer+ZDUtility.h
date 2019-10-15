//
//  CALayer+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/5/27.
//
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (ZDUtility)

- (UIImage *)zd_snapshotImage;
- (nullable NSData *)zd_snapshotPDF;

/// 暂停、恢复动画
- (void)zd_pauseAnimation;
- (void)zd_resumeAnimation;

@end

#pragma mark -
///====================================================================

@interface CALayer (Frame)

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

@end

NS_ASSUME_NONNULL_END
