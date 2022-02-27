//
//  UserTableViewCell2.m
//  Demo
//
//  Created by Zero.D.Saber on 2022/02/27.
//  Copyright © 2022 Zero.D.Saber. All rights reserved.
//

#import "UserTableViewCell2.h"
#import "UserModel.h"

extern UIColor *ZD_RandomColor(void);

@interface UserTableViewCell2 ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *avatarImgView;///< 图片
@property (nonatomic, strong) UILabel *nickNameLabel; ///< 昵称
@property (nonatomic, strong) UILabel *tagLabel;      ///< 红娘标签
@property (nonatomic, strong) UILabel *locationLabel; ///< 地区
@property (nonatomic, strong) UILabel *infoLabel;     ///< 个人信息
@property (nonatomic, strong) UILabel *noticeLabel;   ///< 宣言
@property (nonatomic, strong) UIButton *chatBtn;      ///< 聊天

@property (nonatomic, strong) ZDFlexLayoutDiv *firstLineDiv;

@end

@implementation UserTableViewCell2

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
    self.contentView.backgroundColor = [UIColor colorWithRed:1 green:193/255.0 blue:222/255.0 alpha:1];
    
    [self.contentView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.paddingHorizontal(YGPointValue(15)).paddingVertical(YGPointValue(5));
    }];
    
    [self.contentView addChild:[self.containerView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow).padding(YGPointValue(10));
        make.alignItems(YGAlignCenter);
    }]];
    
    [self.containerView addChild:[self.avatarImgView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.width(YGPointValue(80)).height(YGPointValue(80));
        make.isEnabled(YES);
    }]];
    
    ZDFlexLayoutDiv *rightContaienrDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {        make.flexDirection(YGFlexDirectionColumn).marginLeft(YGPointValue(10));
        make.width(YGPointValue(UIScreen.mainScreen.bounds.size.width - 115 - 25));
    }];
    [self.containerView addChild:rightContaienrDiv];
    
    // 第一行
    ZDFlexLayoutDiv *firstLineDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {       make.flexDirection(YGFlexDirectionRow).justifyContent(YGJustifySpaceBetween);
        make.alignItems(YGAlignCenter);
    }];
    self.firstLineDiv = firstLineDiv;
    [self.nickNameLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexShrink(1);
    }];
    [self.tagLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.paddingHorizontal(YGPointValue(5)).paddingVertical(YGPointValue(2.5));
        make.marginLeft(YGPointValue(3));
    }];
    ZDFlexLayoutDiv *nameTagDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.flexDirection(YGFlexDirectionRow).alignItems(YGAlignCenter).flexShrink(1);
    }];
    [self.locationLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.marginLeft(YGPointValue(5));
    }];
    [nameTagDiv addChildren:@[self.nickNameLabel, self.tagLabel]];
    [firstLineDiv addChildren:@[nameTagDiv, self.locationLabel]];
    
    // 第二行
    [self.infoLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.marginTop(YGPointValue(7));
    }];
    
    // 第三行
    ZDFlexLayoutDiv *thirdLineDiv = [ZDFlexLayoutDiv zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.flexDirection(YGFlexDirectionRow).justifyContent(YGJustifySpaceBetween);
        make.alignItems(YGAlignCenter).marginTop(YGPointValue(5));
    }];
    [self.noticeLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexShrink(1);
    }];
    [self.chatBtn zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.width(YGPointValue(19)).height(YGPointValue(18));
        make.isEnabled(YES);
    }];
    [thirdLineDiv addChildren:@[self.noticeLabel, self.chatBtn]];
    
#if 1
    [rightContaienrDiv addChildren:@[firstLineDiv, self.infoLabel, thirdLineDiv]];
#else
    [rightContaienrDiv addChildren:@[thirdLineDiv]];
    [rightContaienrDiv insertChild:firstLineDiv atIndex:0];
    [rightContaienrDiv insertChild:self.infoLabel atIndex:1];
#endif
}

- (void)setModel:(UserModel *)model {
    if (_model == model) return;
    _model = model;
    
    self.tagLabel.gone = model.is_match_maker == 0;
    
    self.nickNameLabel.text = model.name;
    self.locationLabel.text = model.city;
    self.infoLabel.text = model.list_show_text;
    self.noticeLabel.text = model.marry_declare;
    
    self.firstLineDiv.gone = model.flag;
    
    // 子节点置为markDirty状态，否则yoga会使用缓存高度，不会重新计算
    [self.nickNameLabel markDirty];
    [self.tagLabel markDirty];
    [self.locationLabel markDirty];
    [self.infoLabel markDirty];
    [self.noticeLabel markDirty];
}

- (void)chatAction {
    self.model.flag = !self.model.flag;
    self.firstLineDiv.gone = self.model.flag;
}

#pragma mark -

- (BOOL)autoRefreshLayout {
    return YES;
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
        node.textColor = [UIColor colorWithRed:46/255.0 green:39/255.0 blue:170/255.0 alpha:1];
        _nickNameLabel = node;
    }
    return _nickNameLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        UILabel *node = [UILabel new];
        node.text = @"认证真人";
        node.backgroundColor = [UIColor colorWithRed:218/255.0 green:102/255.0 blue:250/255.0 alpha:1];
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
        node.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
        node.textAlignment = NSTextAlignmentRight;
        _locationLabel = node;
    }
    return _locationLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:12];
        node.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
        _infoLabel = node;
    }
    return _infoLabel;
}

- (UILabel *)noticeLabel {
    if (!_noticeLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:13];
        node.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
        _noticeLabel = node;
    }
    return _noticeLabel;
}

- (UIButton *)chatBtn {
    if (!_chatBtn) {
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.backgroundColor = ZD_RandomColor();
        [view addTarget:self action:@selector(chatAction) forControlEvents:UIControlEventTouchUpInside];
        _chatBtn = view;
    }
    return _chatBtn;
}

@end

/*
 - (void)setupUI2 {
     self.contentView.backgroundColor = ZD_RGB(255, 193, 222);
     
     [self.contentView configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.paddingHorizontal = YGPointValue(15);
         layout.paddingVertical = YGPointValue(5);
     }];
     
     [self.containerView configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.padding = YGPointValue(10);
         layout.alignItems = YGAlignCenter;
     }];
     [self.contentView addChild:self.containerView];
     
     
     [self.avatarImgView configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.width = YGPointValue(80);
         layout.height = YGPointValue(80);
     }];
     [self.containerView addChild:self.avatarImgView];
     
     ZDFlexLayoutDiv *rightContaienrDiv = [ZDFlexLayoutDiv new];
     [rightContaienrDiv configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionColumn;
         layout.marginLeft = YGPointValue(10);
         layout.width = YGPointValue(ZD_ScreenWidth() - 115 - 25);
     }];
     [self.containerView addChild:rightContaienrDiv];
     
     // 第一行
     ZDFlexLayoutDiv *firstLineDiv = ZDFlexLayoutDiv.new;
     [firstLineDiv configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.justifyContent = YGJustifySpaceBetween;
         layout.alignItems = YGAlignCenter;
     }];
     [self.nickNameLabel configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexShrink = 1;
     }];
     [self.tagLabel configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.paddingHorizontal = YGPointValue(5);
         layout.paddingVertical = YGPointValue(2.5);
         layout.marginLeft = YGPointValue(3);
     }];
     ZDFlexLayoutDiv *nameTagDiv = ZDFlexLayoutDiv.new;
     [nameTagDiv configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.alignItems = YGAlignCenter;
         layout.flexShrink = 1;
     }];
     [self.locationLabel configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.marginLeft = YGPointValue(5);
     }];
     [nameTagDiv addChild:self.nickNameLabel];
     [nameTagDiv addChild:self.tagLabel];
     [firstLineDiv addChild:nameTagDiv];
     [firstLineDiv addChild:self.locationLabel];
     
     // 第二行
     [self.infoLabel configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.marginTop = YGPointValue(7);
     }];
     
     // 第三行
     ZDFlexLayoutDiv *thirdLineDiv = ZDFlexLayoutDiv.new;
     [thirdLineDiv configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexDirection = YGFlexDirectionRow;
         layout.justifyContent = YGJustifySpaceBetween;
         layout.alignItems = YGAlignCenter;
         layout.marginTop = YGPointValue(5);
     }];
     [self.noticeLabel configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
         layout.flexShrink = 1;
     }];
     [self.chatBtn configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
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
