//
//  ViewController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "ZDFlexLayoutKit.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self scrollViewLayout];
    //[self normalLayout];
}

- (void)scrollViewLayout {
    [self.view configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.justifyContent = YGJustifyCenter;
    }];
    
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.backgroundColor = UIColor.whiteColor;
    scrollview.alwaysBounceHorizontal = YES;
    [scrollview configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.width = YGPercentValue(100);
        layout.height = YGPercentValue(50);
        //layout.overflow = YGOverflowScroll;
    }];
    [self.view addChild:scrollview];
    
    ZDFlexLayoutView containerDiv = scrollview.zd_contentView;
    [containerDiv configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifyFlexStart;
        layout.height = YGPercentValue(100);
        layout.width = YGValueAuto;
    }];
    
    //==================================================
    
    UIView *view1 = [[UIView alloc] init];
    [view1 setBackgroundColor:[UIColor redColor]];
    [view1 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPercentValue(100);
        layout.width = YGPointValue(300);
    }];
    [containerDiv addChild:view1];

#if 1
    UIView *view2 = [[UIView alloc] init];
    [view2 setBackgroundColor:[UIColor yellowColor]];
    [view2 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPercentValue(100);
        layout.width = YGPointValue(200);
    }];
    [containerDiv addChild:view2];

    UIView *view3 = [[UIView alloc] init];
    [view3 setBackgroundColor:[UIColor purpleColor]];
    [view3 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPercentValue(100);
        layout.width = YGPointValue(400);
    }];
    [containerDiv addChild:view3];

    UIView *view4 = [[UIView alloc] init];
    [view4 setBackgroundColor:[UIColor cyanColor]];
    [view4 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPercentValue(100);
        layout.width = YGPointValue(200);
    }];
    [containerDiv addChild:view4];
#endif

    [self.view calculateLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth];
}

- (void)normalLayout {
    self.view.backgroundColor = UIColor.magentaColor;
    
    self.button.flexLayout.isIncludedInLayout = NO;
    
    [self.view configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.justifyContent = YGJustifySpaceAround;
    }];
    
    self.contentView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.yellowColor;
        view;
    });
    [self.contentView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.height = YGPointValue(300);
        layout.width = YGPointValue(self.view.bounds.size.width);
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifyFlexStart;
        layout.paddingHorizontal = YGPointValue(25);
    }];
    [self.view addChild:self.contentView];
    
    UIView *redView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.redColor;
        view;
    });
    [redView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.flexGrow = 1;
    }];
    [self.contentView addChild:redView];
    
    UIView *blueView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.blueColor;
        view;
    });
    [blueView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.flexGrow = 2;
    }];
    [self.contentView addChild:blueView];
    
    [self.view.flexLayout applyLayoutPreservingOrigin:NO];
}

@end
