//
//  ZDFlexLayoutTableViewCell.m
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/5/22.
//

#import "ZDFlexLayoutTableViewCell.h"
#import "UIView+ZDFlexLayout.h"
#import "ZDFlexLayoutCore.h"

@implementation ZDFlexLayoutTableViewCell

- (BOOL)autoRefreshLayout {
    return NO;
}

- (void)prepareFlexWidthForTargetSize:(CGSize)targetSize {
    if (!self.contentView.isFlexLayoutEnabled) {
        return;
    }
    CGFloat width = targetSize.width;
    if (!(width > 0 && width < CGFLOAT_MAX / 2.0)) {
        width = CGRectGetWidth(self.contentView.bounds);
    }
    if (!(width > 0 && width < CGFLOAT_MAX / 2.0)) {
        width = CGRectGetWidth(self.bounds);
    }
    if (!(width > 0 && width < CGFLOAT_MAX / 2.0)) {
        return;
    }
    CGRect frame = self.contentView.frame;
    frame.size.width = width;
    self.contentView.frame = frame;
    self.contentView.flexLayout.width = YGPointValue(width);
}

- (CGSize)calculateSize {
    [self.contentView calculateLayoutWithAutoRefresh:[self autoRefreshLayout] preservingOrigin:NO dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
    return self.contentView.frame.size;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize {
    CGSize autoLayoutSize = [super systemLayoutSizeFittingSize:targetSize];
    if (self.contentView.isFlexLayoutEnabled) {
        [self prepareFlexWidthForTargetSize:targetSize];
        autoLayoutSize = [self calculateSize];
    }
    return autoLayoutSize;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGSize autoLayoutSize = [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    if (self.contentView.isFlexLayoutEnabled) {
        [self prepareFlexWidthForTargetSize:targetSize];
        autoLayoutSize = [self calculateSize];
    }
    return autoLayoutSize;
}

@end
