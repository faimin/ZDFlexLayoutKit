//
//  ViewController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "AsyncLayoutController.h"
//#import <ZDFlexLayoutKit/ZDFlexLayoutKit.h>
@import ZDFlexLayoutKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *asyncBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    asyncBtn.frame = CGRectMake(43, 430, 343, 50);
    asyncBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    asyncBtn.backgroundColor = UIColor.systemGreenColor;
    asyncBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [asyncBtn setTitle:@"AsyncLayout" forState:UIControlStateNormal];
    [asyncBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [asyncBtn addTarget:self action:@selector(pushAsyncLayout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:asyncBtn];
}

- (void)pushAsyncLayout {
    AsyncLayoutController *vc = [[AsyncLayoutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
