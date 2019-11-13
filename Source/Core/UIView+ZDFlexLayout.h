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

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin;
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility;

@end

#pragma mark - UIScrollView

@interface UIScrollView (ZDFlexLayout)

@property (nonatomic, strong, readonly) ZDFlexLayoutView zd_contentView;

- (BOOL)zd_initedContentView;

- (void)zd_setNeedReLayoutAtNextRunloop:(BOOL)relayout;

@end

NS_ASSUME_NONNULL_END
