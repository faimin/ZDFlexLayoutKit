//
//  ZDBackgroundContainerView.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/2/11.
//

#import "ZDBackgroundContainerView.h"

@implementation ZDBackgroundContainerView

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self _setupTapGesture];
    }
    return self;
}

- (void)_setupTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAction:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
}

#pragma mark - Action

- (void)_tapAction:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    BOOL inSubView = NO;
    for (UIView *tempView in self.subviews) {
        if (CGRectContainsPoint(tempView.frame, location)) {
            inSubView = YES;
            break;
        }
    }
    
    // 点击在子视图上时，不做任何操作
    if (inSubView) {
        return;
    }
    
    if (self.tapActionBlock) {
        self.tapActionBlock(self);
    }
}

@end
