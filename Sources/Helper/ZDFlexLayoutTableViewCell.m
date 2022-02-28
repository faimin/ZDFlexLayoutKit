//
//  ZDFlexLayoutTableViewCell.m
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/5/22.
//

#import "ZDFlexLayoutTableViewCell.h"
#import "UIView+ZDFlexLayout.h"

@implementation ZDFlexLayoutTableViewCell

- (BOOL)autoRefreshLayout {
    return NO;
}

- (CGSize)calculateSize {
    [self.contentView calculateLayoutWithAutoRefresh:[self autoRefreshLayout] preservingOrigin:NO dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
    return self.contentView.frame.size;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize {
    CGSize autoLayoutSize = [super systemLayoutSizeFittingSize:targetSize];
    if (self.contentView.isFlexLayoutEnabled) {
        autoLayoutSize = [self calculateSize];
    }
    return autoLayoutSize;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGSize autoLayoutSize = [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    if (self.contentView.isFlexLayoutEnabled) {
        autoLayoutSize = [self calculateSize];
    }
    return autoLayoutSize;
}

@end
