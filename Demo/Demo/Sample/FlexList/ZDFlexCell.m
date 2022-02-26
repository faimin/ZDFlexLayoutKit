//
//  ZDFlexCell.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/16.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDFlexCell.h"
#import "ZDFlexLayoutKit.h"
#import "TextureModel.h"

extern UIColor *ZD_RandomColor(void);

@interface ZDFlexCell ()
@property (nonatomic, strong) UILabel *titleLabel;    ///< 标题
@property (nonatomic, strong) UILabel *contentLabel;  ///< 内容
@property (nonatomic, strong) UIImageView *aImageView;///< 图片
@property (nonatomic, strong) UILabel *nickNameLabel; ///< 昵称
@property (nonatomic, strong) UILabel *timeLabel;     ///< 时间
@end

@implementation ZDFlexCell

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
    self.contentView.backgroundColor = UIColor.whiteColor;//ZD_RandomColor();
    
    [self.contentView addChild:self.titleLabel];
    [self.contentView addChild:self.contentLabel];
    [self.contentView addChild:self.aImageView];
    
    ZDFlexLayoutDiv *bottomContainerDiv = [[ZDFlexLayoutDiv alloc] init];
    [bottomContainerDiv addChild:self.nickNameLabel];
    [bottomContainerDiv addChild:self.timeLabel];
    [self.contentView addChild:bottomContainerDiv];
    
    self.titleLabel.flexLayout.isEnabled = YES;
    
    [self.contentLabel configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(10);
    }];
    
    [self.aImageView configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(10);
    }];
    
    [bottomContainerDiv configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifySpaceBetween;
        layout.alignContent = YGAlignCenter;
        layout.marginTop = YGPointValue(10);
    }];
    
    [self.contentView configureFlexLayoutWithBlock:^(ZDFlexLayoutCore * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.justifyContent = YGJustifyFlexStart;
        layout.paddingHorizontal = YGPointValue(15);
        layout.paddingVertical = YGPointValue(10);
        layout.width = YGPointValue(UIScreen.mainScreen.bounds.size.width);
    }];
}

- (void)setModel:(TextureModel *)model {
    if (!model) return;
    _model = model;
    
    self.titleLabel.text = model.title;
    self.contentLabel.text = model.content;
    self.aImageView.image = model.imageName.length > 0 ? [UIImage imageNamed:model.imageName] : nil;
    self.nickNameLabel.text = model.username;
    self.timeLabel.text = model.time;
    
    // 根据数据改变layout
    self.contentLabel.flexLayout.marginTop = YGPointValue((model.title.length == 0 || model.content.length == 0) ? 0 : 10);
    self.aImageView.flexLayout.isIncludedInLayout = model.imageName.length > 0;
    
    // 计算layout
    [self.contentView.flexLayout applyLayoutPreservingOrigin:NO dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 子节点置为markDirty状态，否则yoga会使用缓存高度，不会重新计算
    [self.titleLabel.flexLayout markDirty];
    [self.contentLabel.flexLayout markDirty];
    [self.aImageView.flexLayout markDirty];
    [self.nickNameLabel.flexLayout markDirty];
    [self.timeLabel.flexLayout markDirty];
    [self.nickNameLabel.superview.flexLayout markDirty];
}

#pragma mark - Property

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.font = [UIFont systemFontOfSize:18.0];
        node.textColor = ZD_RandomColor();
        _titleLabel = node;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        UILabel *node = [UILabel new];
        node.numberOfLines = 0;
        node.font = [UIFont systemFontOfSize:16.0];
        node.textColor = ZD_RandomColor();
        _contentLabel = node;
    }
    return _contentLabel;
}

- (UIImageView *)aImageView {
    if (!_aImageView) {
        UIImageView *node = [[UIImageView alloc] init];
        node.contentMode = UIViewContentModeLeft;
        _aImageView = node;
    }
    return _aImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.textColor = ZD_RandomColor();
        node.flexLayout.isEnabled = YES;
        _nickNameLabel = node;
    }
    return _nickNameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        UILabel *node = [[UILabel alloc] init];
        node.textColor = ZD_RandomColor();
        node.flexLayout.isEnabled = YES;
        _timeLabel = node;
    }
    return _timeLabel;
}

@end
