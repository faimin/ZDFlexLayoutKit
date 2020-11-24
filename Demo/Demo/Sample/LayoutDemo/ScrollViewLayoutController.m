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
    
    [self.view zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.justifyContent(YGJustifySpaceEvenly);
    }];
    
    [self scrollViewLayout];
    [self textScrollViewLayout];
    
    //[self.view calculateLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleHeight];
    [self.view asyncCalculateLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleHeight];
}

- (void)scrollViewLayout {
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.backgroundColor = UIColor.whiteColor;
    [scrollview zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.width(YGPercentValue(100));
        make.height(YGPercentValue(30));
        make.overflow(YGOverflowScroll);
    }];
    [self.view addChild:scrollview];
    
    ZDFlexLayoutView containerDiv = [scrollview.zd_contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.justifyContent(YGJustifyFlexStart);
        make.height(YGValueAuto);
        make.paddingHorizontal(YGPointValue(20));
    }];
    //==================================================
    
    UIView *view1 = [[UIView alloc] init];
    [view1 setBackgroundColor:[UIColor redColor]];
    [containerDiv addChild:[view1 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(true);
        make.height(YGPercentValue(100));
        make.width(YGPointValue(300));
    }]];

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
}

- (void)textScrollViewLayout {
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.backgroundColor = UIColor.whiteColor;
    [scrollview zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.width(YGPercentValue(100));
        make.height(YGPercentValue(20));
        make.overflow(YGOverflowScroll);
    }];
    [self.view addChild:scrollview];
    
    ZDFlexLayoutView containerDiv = [scrollview.zd_contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.justifyContent(YGJustifyFlexStart);
        make.height(YGValueAuto);
        make.marginHorizontal(YGPointValue(20));
        //make.width(YGPercentValue(100));
    }];
    //==================================================
    
    UILabel *detailLabel = [({
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectZero];
        view.backgroundColor = UIColor.redColor;
        view.textColor = UIColor.yellowColor;
        view.textAlignment = NSTextAlignmentCenter;
        view.font = [UIFont systemFontOfSize:24];
        view.numberOfLines = 0;
        view.text = @" 1.邀请嘉宾上麦 用户进房后主动邀请用户上麦，可以说“欢迎大家来到我的直播间，有想上麦的可以主动申请，上来聊聊天” 2. 让嘉宾互相了解 只有一个嘉宾上麦时可以先和嘉宾聊聊，了解一下她/他的基本信息和择偶标准； 两个嘉宾在麦时，可以主动介绍双方嘉宾的信息或者引导男女嘉宾自我介绍 自我介绍之后可以让男女嘉宾互相提问，1-3个问题不等 红娘也要做一个活跃氛围的小能手，让嘉宾之间迅速摆脱尴尬，例如问“女嘉宾觉得男嘉宾怎么样呢” 3.引导嘉宾互相关注 麦上嘉宾互相感兴趣，红娘可以引导嘉宾互相关注 也可以让嘉宾互送一个小礼物，增进感情 不要在用户刚上麦，或者一个新用户刚来的时候就让用户送礼 4.换嘉宾上麦 语气一定要温柔，可以说“男嘉宾，可以和你商量一下吗，下面还有其他男嘉宾在等着，也给他们一点机会，把你先抱下麦，可以吗？” ";
        view;
    }) zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        //make.width(YGPercentValue(100));
    }];
    [containerDiv addChild:detailLabel];
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
