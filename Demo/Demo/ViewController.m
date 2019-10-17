//
//  ViewController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import <YogaKit/UIView+Yoga.h>
@import YogaKit;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self yogaDemo2];
}

- (void)yogaDemo1 {
    self.button.yoga.isIncludedInLayout = false;
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self.view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(self.view.bounds.size.width);
        layout.height = YGPointValue(self.view.bounds.size.height);
        layout.alignItems = YGAlignCenter;
        layout.justifyContent = YGJustifyCenter;
    }];

    UIView *child1 = [UIView new];
    child1.backgroundColor = [UIColor blueColor];
    child1.yoga.isEnabled = YES;
    child1.yoga.width = YGPointValue(100);
    child1.yoga.height = YGPointValue(100);

    //-------------------------------
    
    UIView *child2 = [UIView new];
    child2.yoga.isEnabled = true;
    child2.backgroundColor = [UIColor greenColor];
    child2.frame = (CGRect) {
        .size = {
            .width = 200,
            .height = 100,
        }
    };

    UIView *child3 = [UIView new];
    child3.yoga.isEnabled = YES;
    child3.backgroundColor = [UIColor yellowColor];
    child3.frame = (CGRect) {
        .size = {
            .width = 100,
            .height = 100,
        }
    };

    //-------------------------------
    
    [child2 addSubview:child3];
    [self.view addSubview:child1];
    [self.view addSubview:child2];
    [self.view.yoga applyLayoutPreservingOrigin:NO];
}

- (void)yogaDemo2 {
    self.view.backgroundColor = UIColor.grayColor;
    
    self.button.yoga.isIncludedInLayout = NO;
    
    [self.view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.justifyContent = YGJustifySpaceAround;
    }];
    
    UIView *contentView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.yellowColor;
        view;
    });
    [contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.height = YGPointValue(300);
        layout.width = YGPointValue(self.view.bounds.size.width);
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifyCenter;
        layout.paddingHorizontal = YGPointValue(25);
    }];
    [self.view addSubview:contentView];
    
    UIView *redView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.redColor;
        view;
    });
    [redView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.flexGrow = 1;
        layout.flexShrink = 1;
    }];
    [contentView addSubview:redView];
    
    UIView *blueView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.blueColor;
        view;
    });
    [blueView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.flexGrow = 1;
    }];
    [contentView addSubview:blueView];
    
    [self.view.yoga applyLayoutPreservingOrigin:NO];
}

@end
