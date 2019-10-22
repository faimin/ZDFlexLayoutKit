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

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self yogaDemo];
}

- (void)yogaDemo {
    self.view.backgroundColor = UIColor.grayColor;
    
    self.button.flexLayout.isIncludedInLayout = NO;
    
    [self.view configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.justifyContent = YGJustifySpaceAround;
    }];
    
    UIView *contentView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.yellowColor;
        view;
    });
    [contentView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.height = YGPointValue(300);
        layout.width = YGPointValue(self.view.bounds.size.width);
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifyCenter;
        layout.paddingHorizontal = YGPointValue(25);
    }];
    [self.view addChild:contentView];
    
    UIView *redView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.redColor;
        view;
    });
    [redView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.flexGrow = 1;
        layout.flexShrink = 1;
    }];
    [contentView addChild:redView];
    
    UIView *blueView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.blueColor;
        view;
    });
    [blueView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
        layout.isEnabled = true;
        layout.flexGrow = 1;
    }];
    [contentView addChild:blueView];
    
    [self.view.flexLayout applyLayoutPreservingOrigin:NO];
}

@end
