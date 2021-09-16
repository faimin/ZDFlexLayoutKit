//
//  UIView+ZDFlexLayoutCore.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDFlexLayoutViewProtocol.h"
#import "ZDFlexLayoutDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZDFlexLayout) <ZDFlexLayoutViewProtocol>

/// 将视图标记为dirty（yoga中仅仅对叶子视图生效），
/// 同时会把根视图标记为dirty，然后在下一个runloop时刷新
- (void)markDirty;

/// 计算布局
/// @param autoRefresh 是否开启runloop自动更新布局（默认false）
/// @param preserveOrigin 是否保留原来的布局属性
- (void)calculateLayoutWithAutoRefresh:(BOOL)autoRefresh
                      preservingOrigin:(BOOL)preserveOrigin;
- (void)calculateLayoutPreservingOrigin:(BOOL)preserveOrigin;

/// 计算布局
/// @param autoRefresh 是否开启runloop自动更新布局（默认false）
/// @param preserveOrigin 是否保留原来的布局属性
/// @param dimensionFlexibility 横向是flex的还是纵向是flex的
- (void)calculateLayoutWithAutoRefresh:(BOOL)autoRefresh
                      preservingOrigin:(BOOL)preserveOrigin
                  dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility;
- (void)calculateLayoutPreservingOrigin:(BOOL)preserveOrigin
                   dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility;

/// 在子线程计算布局（不推荐）
/// 内部牵扯到锁与线程切换带来的性能损耗，性能并不比同步好;
- (void)asyncCalculateLayoutPreservingOrigin:(BOOL)preserveOrigin __attribute__((deprecated("use calculateLayoutWithAutoRefresh:preservingOrigin: instead")));
- (void)asyncCalculateLayoutPreservingOrigin:(BOOL)preserveOrigin
                        dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility __attribute__((deprecated("use calculateLayoutWithAutoRefresh:preservingOrigin:dimensionFlexibility: instead")));

@end

#pragma mark - UIScrollView

@class ZDFlexLayoutDiv;
@interface UIScrollView (ZDFlexLayout)

@property (nonatomic, strong, readonly) ZDFlexLayoutDiv *zd_contentView;

/// whether had initialized contentView
- (BOOL)zd_initedContentView;

/// 添加下一个runloop是否需要刷新的标记
/// @param relayout 是否需要刷新布局
- (void)zd_setNeedReLayoutAtNextRunloop:(BOOL)relayout;

@end

NS_ASSUME_NONNULL_END
