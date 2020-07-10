//
//  UIView+ZDFlexLayout.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDFlexLayoutViewProtocol.h"
#import "ZDFlexLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZDFlexLayout) <ZDFlexLayoutViewProtocol>

- (void)markDirty;

- (void)calculateLayoutPreservingOrigin:(BOOL)preserveOrigin;
- (void)calculateLayoutPreservingOrigin:(BOOL)preserveOrigin
                   dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility;
/// 异步计算布局（不推荐）
/// 内部牵扯到锁与线程切换带来的性能损耗，性能并不比同步好;
- (void)asyncCalculateLayoutPreservingOrigin:(BOOL)preserveOrigin;
- (void)asyncCalculateLayoutPreservingOrigin:(BOOL)preserveOrigin
                        dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility;

@end

#pragma mark - UIScrollView

@class ZDFlexLayoutDiv;
@interface UIScrollView (ZDFlexLayout)

@property (nonatomic, strong, readonly) ZDFlexLayoutDiv *zd_contentView;

/// whether had initialized contentView
- (BOOL)zd_initedContentView;

- (void)zd_setNeedReLayoutAtNextRunloop:(BOOL)relayout;

@end

NS_ASSUME_NONNULL_END
