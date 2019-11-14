//
//  ScrollViewLayoutController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/11/14.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ScrollViewLayoutController.h"
#import "ZDFlexLayoutKit.h"

@interface ScrollViewLayoutController ()

@end

@implementation ScrollViewLayoutController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self scrollViewLayout];
}

- (void)scrollViewLayout {
    [self.view zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.justifyContent(YGJustifyCenter);
    }];
    
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.backgroundColor = UIColor.whiteColor;
    scrollview.alwaysBounceHorizontal = YES;
    [scrollview zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.width(YGPercentValue(100));
        make.height(YGPercentValue(50));
        //~~layout.overflow(YGOverflowScroll);~~
    }];
    [self.view addChild:scrollview];
    
    ZDFlexLayoutView containerDiv = [scrollview.zd_contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.justifyContent(YGJustifyFlexStart);
        make.height(YGPercentValue(100));
        make.width(YGValueAuto);
    }];
    //==================================================
    
    UIView *view1 = [[UIView alloc] init];
    [view1 setBackgroundColor:[UIColor redColor]];
    [containerDiv addChild:[view1 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(true);
        make.height(YGPercentValue(100));
        make.width(YGPointValue(300));
    }]];

#if 1
    UIView *view2 = [[UIView alloc] init];
    [view2 setBackgroundColor:[UIColor yellowColor]];
    [view2 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.height(YGPercentValue(100));
        make.width(YGPointValue(200));
    }];
    [containerDiv addChild:view2];

    UIView *view3 = [[UIView alloc] init];
    [view3 setBackgroundColor:[UIColor purpleColor]];
    [view3 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.height(YGPercentValue(100));
        make.width(YGPointValue(400));
    }];
    [containerDiv addChild:view3];

    UIView *view4 = [[UIView alloc] init];
    [view4 setBackgroundColor:[UIColor cyanColor]];
    [view4 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.height(YGPercentValue(100));
        make.width(YGPointValue(200));
    }];
    [containerDiv addChild:view4];
#endif

    [self.view calculateLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
