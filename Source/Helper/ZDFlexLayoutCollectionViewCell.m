//
//  ZDFlexLayoutCollectionViewCell.m
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/5/22.
//

#import "ZDFlexLayoutCollectionViewCell.h"
#import "UIView+ZDFlexLayout.h"

@implementation ZDFlexLayoutCollectionViewCell

- (CGSize)calculateSize {
    [self.contentView calculateLayoutPreservingOrigin:NO dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
    return self.contentView.frame.size;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize {
    if (self.contentView.isFlexLayoutEnabled) {
        return [self calculateSize];
    }
    else {
        return [super systemLayoutSizeFittingSize:targetSize];
    }
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    if (self.contentView.isFlexLayoutEnabled) {
        return [self calculateSize];
    }
    else {
        return [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    }
}

@end
