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
    [self yogaDemo];
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
