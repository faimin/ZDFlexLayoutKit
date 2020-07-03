//
//  NormalLayoutController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/11/14.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "NormalLayoutController.h"
#import "ZDFlexLayoutKit.h"

@interface NormalLayoutController ()

@property (nonatomic, strong) UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation NormalLayoutController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self normalLayout];
}

- (void)normalLayout {
    self.view.backgroundColor = UIColor.magentaColor;
    
//    self.button.flexLayout.isIncludedInLayout = NO;
    
    [self.view zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn).justifyContent(YGJustifyFlexStart);
    }];
    
    ZDFlexLayoutDiv *aDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.position(YGPositionTypeAbsolute);
        make.flexDirection(YGFlexDirectionRow);
        make.marginTop(YGPointValue(15));
        make.alignSelf(YGAlignFlexEnd);
    }];
    UIView *aView = [({
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = UIColor.cyanColor;
        v;
    }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.width(YGPointValue(100)).height(YGPointValue(50));
        make.marginRight(YGPointValue(50));
    }];
    [self.view addChild:aDiv];
    [aDiv addChild:aView];
    
    self.contentView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.yellowColor;
        view;
    });
    [self.contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.marginTop(YGPointValue(300));
        make.width(YGPercentValue(100));
        //make.height(YGPointValue(300));
        make.aspectRatio(2.0);  // width / height
        make.flexDirection(YGFlexDirectionRow).justifyContent(YGJustifyFlexStart);
        make.paddingHorizontal(YGPointValue(25));
    }];
    [self.view addChild:self.contentView];
    
    UIView *redView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.redColor;
        view;
    });
    [redView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES).flexGrow(1);
    }];
    [self.contentView addChild:redView];
    
    UIView *blueView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.blueColor;
        view;
    });
    [blueView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(true).flexGrow(2);
    }];
    [self.contentView addChild:blueView];
    
//    [self.view calculateLayoutPreservingOrigin:YES];
    [self.view asyncCalculateLayoutPreservingOrigin:YES];
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
