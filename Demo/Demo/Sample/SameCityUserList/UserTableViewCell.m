//
//  UserTableViewCell.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "UserTableViewCell.h"
#import "ZDFlexLayoutKit.h"
#import <ZDFunction.h>
#import <ZDToolKit.h>

@interface UserTableViewCell ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *avatarImgView;///< 图片
@property (nonatomic, strong) UILabel *nickNameLabel; ///< 昵称
@property (nonatomic, strong) UILabel *tagLabel;      ///< 红娘标签
@property (nonatomic, strong) UILabel *locationLabel; ///< 地区
@property (nonatomic, strong) UILabel *infoLabel;     ///< 个人信息
@property (nonatomic, strong) UILabel *noticeLabel;   ///< 宣言
@property (nonatomic, strong) UIButton *chatBtn;      ///< 聊天
@end

@implementation UserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupUI];
}

- (void)setupUI {
    self.contentView.backgroundColor = ZD_RGB(255, 193, 222);
    
    [self.contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.paddingHorizontal(YGPointValue(15)).paddingVertical(YGPointValue(5));
    }];
    
    [self.contentView addChild:[self.containerView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {  make.flexDirection(YGFlexDirectionRow).padding(YGPointValue(10)).alignItems(YGAlignCenter);
    }]];
    
    [self.containerView addChild:[self.avatarImgView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.width(YGPointValue(80)).height(YGPointValue(80));
    }]];
    
    ZDFlexLayoutDiv *rightContaienrDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {        make.flexDirection(YGFlexDirectionColumn).marginLeft(YGPointValue(10)).width(YGPointValue(ZD_ScreenWidth() - 115 - 25));
    }];
    [self.containerView addChild:rightContaienrDiv];
    
    // 第一行
    ZDFlexLayoutDiv *firstLineDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {       make.flexDirection(YGFlexDirectionRow).justifyContent(YGJustifySpaceBetween).alignItems(YGAlignCenter);
    }];
    self.nickNameLabel.flexLayout.flexShrink = 1;
    [self.tagLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.paddingHorizontal(YGPointValue(5)).paddingVertical(YGPointValue(2.5)).marginLeft(YGPointValue(3));
    }];
    ZDFlexLayoutDiv *nameTagDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.flexDirection(YGFlexDirectionRow).alignItems(YGAlignCenter).flexShrink(1);
    }];
    self.locationLabel.flexLayout.marginLeft = YGPointValue(5);
    [nameTagDiv addChildren:@[self.nickNameLabel, self.tagLabel]];
    [firstLineDiv addChildren:@[nameTagDiv, self.locationLabel]];
    
    // 第二行
    self.infoLabel.flexLayout.marginTop = YGPointValue(7);
    
    // 第三行
    ZDFlexLayoutDiv *thirdLineDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.flexDirection(YGFlexDirectionRow).justifyContent(YGJustifySpaceBetween).alignItems(YGAlignCenter).marginTop(YGPointValue(5));
    }];
    self.noticeLabel.flexLayout.flexShrink = 1;
    [self.chatBtn zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.width(YGPointValue(19)).height(YGPointValue(18));
    }];
    [thirdLineDiv addChildren:@[self.noticeLabel, self.chatBtn]];
    
    [rightContaienrDiv addChildren:@[firstLineDiv, self.infoLabel, thirdLineDiv]];
}

- (void)setModel:(UserModel *)model {
    if (_model == model) return;
    _model = model;
    
    self.tagLabel.text = model.is_match_maker == 1 ? @"认证红娘" : nil;
    self.tagLabel.flexLayout.isIncludedInLayout = model.is_match_maker == 1;
    self.tagLabel.hidden = model.is_match_maker == 0;
    
    self.nickNameLabel.text = model.name;
    self.locationLabel.text = model.city;
    self.infoLabel.text = model.list_show_text;
    self.noticeLabel.text = model.marry_declare;
    
    // 子节点置为markDirty状态，否则yoga会使用缓存高度，不会重新计算
    [self.nickNameLabel markDirty];
    [self.tagLabel markDirty];
    [self.locationLabel markDirty];
    [self.infoLabel markDirty];
    [self.noticeLabel markDirty];
    
    // 计算layout
    [self.contentView applyLayoutPreservingOrigin:NO dimensionFlexibility:YGDimensionFlexibilityFlexibleHeight];
}

#pragma mark - Property

- (UIView *)containerView {
    if (!_containerView) {
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.whiteColor;
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
        _containerView = view;
    }
    return _containerView;
}

- (UIImageView *)avatarImgView {
    if (!_avatarImgView) {
        UIImageView *node = [[UIImageView alloc] init];
        node.backgroundColor = ZD_RandomColor();
        node.layer.cornerRadius = 5;
        node.layer.masksToBounds = YES;
        node.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImgView = node;
    }
    return _avatarImgView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:16.0];
        node.textColor = ZD_RGB(46, 39, 42);
        _nickNameLabel = node;
    }
    return _nickNameLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        UILabel *node = [UILabel new];
        node.backgroundColor = ZD_RGB(218, 102, 250);
        node.numberOfLines = 1;
        node.font = [UIFont boldSystemFontOfSize:9];
        node.textColor = UIColor.whiteColor;
        node.textAlignment = NSTextAlignmentCenter;
        node.layer.cornerRadius = 8;
        node.layer.masksToBounds = YES;
        _tagLabel = node;
    }
    return _tagLabel;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:12];
        node.textColor = ZD_RGB(170, 170, 170);
        node.textAlignment = NSTextAlignmentRight;
        _locationLabel = node;
    }
    return _locationLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:12];
        node.textColor = ZD_RGB(170, 170, 170);
        _infoLabel = node;
    }
    return _infoLabel;
}

- (UILabel *)noticeLabel {
    if (!_noticeLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:13];
        node.textColor = ZD_RGB(170, 170, 170);
        _noticeLabel = node;
    }
    return _noticeLabel;
}

- (UIButton *)chatBtn {
    if (!_chatBtn) {
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.backgroundColor = ZD_RandomColor();
        _chatBtn = view;
    }
    return _chatBtn;
}

@end

/*
 - (void)setupUI2 {
     self.contentView.backgroundColor = ZD_RGB(255, 193, 222);
     
     [self.contentView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.paddingHorizontal = YGPointValue(15);
         layout.paddingVertical = YGPointValue(5);
     }];
     
     [self.containerView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.padding = YGPointValue(10);
         layout.alignItems = YGAlignCenter;
     }];
     [self.contentView addChild:self.containerView];
     
     
     [self.avatarImgView configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.width = YGPointValue(80);
         layout.height = YGPointValue(80);
     }];
     [self.containerView addChild:self.avatarImgView];
     
     ZDFlexLayoutDiv *rightContaienrDiv = [ZDFlexLayoutDiv new];
     [rightContaienrDiv configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionColumn;
         layout.marginLeft = YGPointValue(10);
         layout.width = YGPointValue(ZD_ScreenWidth() - 115 - 25);
     }];
     [self.containerView addChild:rightContaienrDiv];
     
     // 第一行
     ZDFlexLayoutDiv *firstLineDiv = ZDFlexLayoutDiv.new;
     [firstLineDiv configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.justifyContent = YGJustifySpaceBetween;
         layout.alignItems = YGAlignCenter;
     }];
     [self.nickNameLabel configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexShrink = 1;
     }];
     [self.tagLabel configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.paddingHorizontal = YGPointValue(5);
         layout.paddingVertical = YGPointValue(2.5);
         layout.marginLeft = YGPointValue(3);
     }];
     ZDFlexLayoutDiv *nameTagDiv = ZDFlexLayoutDiv.new;
     [nameTagDiv configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.alignItems = YGAlignCenter;
         layout.flexShrink = 1;
     }];
     [self.locationLabel configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.marginLeft = YGPointValue(5);
     }];
     [nameTagDiv addChild:self.nickNameLabel];
     [nameTagDiv addChild:self.tagLabel];
     [firstLineDiv addChild:nameTagDiv];
     [firstLineDiv addChild:self.locationLabel];
     
     // 第二行
     [self.infoLabel configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.marginTop = YGPointValue(7);
     }];
     
     // 第三行
     ZDFlexLayoutDiv *thirdLineDiv = ZDFlexLayoutDiv.new;
     [thirdLineDiv configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.justifyContent = YGJustifySpaceBetween;
         layout.alignItems = YGAlignCenter;
         layout.marginTop = YGPointValue(5);
     }];
     [self.noticeLabel configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.flexShrink = 1;
     }];
     [self.chatBtn configureFlexLayoutWithBlock:^(ZDFlexLayout * _Nonnull layout) {
         layout.width = YGPointValue(19);
         layout.height = YGPointValue(18);
     }];
     [thirdLineDiv addChild:self.noticeLabel];
     [thirdLineDiv addChild:self.chatBtn];
     
     [rightContaienrDiv addChild:firstLineDiv];
     [rightContaienrDiv addChild:self.infoLabel];
     [rightContaienrDiv addChild:thirdLineDiv];
 }
 */
