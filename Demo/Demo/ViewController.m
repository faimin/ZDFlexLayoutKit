//
//  ViewController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "AsyncLayoutController.h"
@import ZDFlexLayoutKit;

@interface ViewController ()

@property (nonatomic, strong) UIButton *asyncBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *asyncBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    asyncBtn.translatesAutoresizingMaskIntoConstraints = NO;
    asyncBtn.backgroundColor = UIColor.systemGreenColor;
    asyncBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [asyncBtn setTitle:@"AsyncLayout" forState:UIControlStateNormal];
    [asyncBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [asyncBtn addTarget:self action:@selector(pushAsyncLayout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:asyncBtn];
    self.asyncBtn = asyncBtn;

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [asyncBtn.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:20],
        [asyncBtn.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-20],
        [asyncBtn.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:-40],
        [asyncBtn.heightAnchor constraintEqualToConstant:50],
    ]];
}

- (void)pushAsyncLayout {
    AsyncLayoutController *vc = [[AsyncLayoutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
