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
//    [self test];
    [self yogaDemo];
}

- (void)test {
    [self.view configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.backgroundColor = UIColor.whiteColor;
    scrollview.alwaysBounceVertical = YES;
    [self.view addChild:scrollview];
    [scrollview configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPercentValue(100);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.overflow = YGOverflowScroll; // 需要设置
    }];
    ZDFlexLayoutDiv *containerDiv = scrollview.zd_contentView;
    
    UIView *view1 = [[UIView alloc] init];
    [view1 setBackgroundColor:[UIColor redColor]];
    [containerDiv addChild:view1];
    [view1 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(300);
    }];

    UIView *view2 = [[UIView alloc] init];
    [view2 setBackgroundColor:[UIColor yellowColor]];
    [containerDiv addChild:view2];
    [view2 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(200);
    }];

    UIView *view3 = [[UIView alloc] init];
    [view3 setBackgroundColor:[UIColor purpleColor]];
    [containerDiv addChild:view3];
    [view3 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(400);
    }];

    UIView *view4 = [[UIView alloc] init];
    [view4 setBackgroundColor:[UIColor cyanColor]];
    [containerDiv addChild:view4];
    [view4 configureFlexLayoutWithBlock:^(ZDFlexLayout *_Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(200);
    }];

    [self.view.flexLayout applyLayoutPreservingOrigin:NO];
}

- (void)yogaDemo {
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
        //layout.flexShrink = 1;
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.contentView.flexLayout.width = YGPointValue(self.view.bounds.size.width);
    for (UIView *view in self.contentView.subviews) {
        [view.flexLayout markDirty];
    }
    [self.view.flexLayout applyLayoutPreservingOrigin:NO];
}

@end
