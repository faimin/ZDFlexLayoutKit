//
//  NormalLayoutController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/11/14.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "NormalLayoutController.h"
@import ZDFlexLayoutKit;

@interface NormalLayoutController ()

@property (nonatomic, strong) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation NormalLayoutController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 从导航栏底部开始布局
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self normalLayout];
}

- (void)normalLayout {
    self.view.backgroundColor = UIColor.magentaColor;
    //self.button.flexLayout.isIncludedInLayout = NO;
    
    [self.view zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn).justifyContent(YGJustifyFlexStart);
    }];
    
    //flex相对布局
    {
        self.contentView = [({
            UIView *view = UIView.new;
            view.backgroundColor = UIColor.yellowColor;
            view;
        }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES);
            make.marginTop(YGPointValue(300));
            make.width(YGPercentValue(100));
            make.aspectRatio(2.0);  // width / height
            make.flexDirection(YGFlexDirectionRow).justifyContent(YGJustifyFlexStart);
            make.paddingHorizontal(YGPointValue(25));
        }];
        [self.view addChild:self.contentView];
        
        UIView *redView = [({
            UIView *view = UIView.new;
            view.backgroundColor = UIColor.redColor;
            view;
        }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES).flexGrow(1);
        }];
        [self.contentView addChild:redView];
        
        UIView *blueView = [({
            UIView *view = UIView.new;
            view.backgroundColor = UIColor.blueColor;
            view;
        }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(true).flexGrow(2);
        }];
        [self.contentView addChild:blueView];
    }
    
    // flex绝对布局
    {
        UIView *aView = [({
            UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
            v.backgroundColor = UIColor.purpleColor;
            v;
        }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.position(YGPositionTypeAbsolute);
            make.width(YGPointValue(100)).aspectRatio(1.5);
            make.top(YGPointValue(100)).right(YGPointValue(50));
        }];
        [self.view addChild:aView];
        
        UIView *bView = [({
            UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
            v.backgroundColor = UIColor.orangeColor;
            v;
        }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.position(YGPositionTypeAbsolute);
            make.width(YGPointValue(100)).height(YGPointValue(100));
            make.top(YGPointValue(100)).left(YGPointValue(50));
        }];
        [self.view addChild:bView];
    }
    
    [self.view calculateLayoutWithAutoRefresh:YES preservingOrigin:YES];
}

- (IBAction)movePostion:(UIButton *)sender forEvent:(UIEvent *)event {
    [self.contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        CGFloat percent = self.contentView.flexLayout.width.value;
        make.width(YGPercentValue(MAX(30, percent - 10)));
        make.markDirty();
    }];
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
