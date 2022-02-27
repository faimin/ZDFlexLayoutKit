//
//  ZDFlexLayoutTableViewCell.m
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/5/22.
//

#import "ZDFlexLayoutTableViewCell.h"
#import "UIView+ZDFlexLayout.h"

@implementation ZDFlexLayoutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

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
        CGRect willUpdatedFrame = self.contentView.frame;
        willUpdatedFrame.size = targetSize;
        self.contentView.frame = willUpdatedFrame;
        return [self calculateSize];
    }
    else {
        return [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    }
}

@end
