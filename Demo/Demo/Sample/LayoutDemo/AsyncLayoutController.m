//
//  AsyncLayoutController.m
//  Demo
//
//  Created by Zero.D.Saber on 2024/12/1.
//

#import "AsyncLayoutController.h"
@import ZDFlexLayoutKit;

@interface AsyncLayoutController ()

@property (nonatomic, strong) UIView *syncContainer;
@property (nonatomic, strong) UIView *idleContainer;
@property (nonatomic, strong) UIView *asyncContainer;
@property (nonatomic, strong) UISegmentedControl *modeSegment;
@property (nonatomic, assign) ZDFlexLayoutAsyncMode currentMode;
@property (nonatomic, assign) CGSize lastLayoutSize;

@end

@implementation AsyncLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Async Layout Demo";
    self.view.backgroundColor = UIColor.whiteColor;
    self.currentMode = ZDFlexLayoutAsyncModeSync;

    [self setupModeSelector];
    [self buildLayoutWithMode:self.currentMode];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = self.view.bounds.size;
    if (CGSizeEqualToSize(size, self.lastLayoutSize)) {
        return;
    }
    BOOL hadSize = self.lastLayoutSize.width > 0 && self.lastLayoutSize.height > 0;
    self.lastLayoutSize = size;
    [self layoutChrome];
    if (hadSize) {
        [self clearLayout];
        [self buildLayoutWithMode:self.currentMode];
    } else if (self.syncContainer || self.idleContainer || self.asyncContainer) {
        [self layoutActiveContainer];
    }
}

#pragma mark - Mode Selector

- (void)setupModeSelector {
    self.modeSegment = [[UISegmentedControl alloc] initWithItems:@[@"Sync", @"RunLoop Idle", @"Background Thread"]];
    self.modeSegment.selectedSegmentIndex = 0;
    [self.modeSegment addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.modeSegment];
}

- (void)layoutChrome {
    CGFloat top = self.view.safeAreaInsets.top + 12;
    CGFloat leading = self.view.safeAreaInsets.left + 20;
    CGFloat trailing = self.view.safeAreaInsets.right + 20;
    CGFloat width = CGRectGetWidth(self.view.bounds) - leading - trailing;
    self.modeSegment.frame = CGRectMake(leading, top, width, 36);
}

- (void)modeChanged:(UISegmentedControl *)sender {
    [self clearLayout];
    switch (sender.selectedSegmentIndex) {
        case 0: self.currentMode = ZDFlexLayoutAsyncModeSync; break;
        case 1: self.currentMode = ZDFlexLayoutAsyncModeRunloopIdle; break;
        case 2: self.currentMode = ZDFlexLayoutAsyncModeBackgroundThread; break;
        default: self.currentMode = ZDFlexLayoutAsyncModeSync; break;
    }
    [self buildLayoutWithMode:self.currentMode];
}

#pragma mark - Layout Construction

- (void)clearLayout {
    [self.syncContainer removeFromSuperview];
    [self.idleContainer removeFromSuperview];
    [self.asyncContainer removeFromSuperview];
    self.syncContainer = nil;
    self.idleContainer = nil;
    self.asyncContainer = nil;
}

- (CGRect)containerFrame {
    CGFloat top = CGRectGetMaxY(self.modeSegment.frame) + 12;
    CGFloat leading = self.view.safeAreaInsets.left;
    CGFloat trailing = self.view.safeAreaInsets.right;
    CGFloat bottom = self.view.safeAreaInsets.bottom;
    return CGRectMake(leading,
                      top,
                      CGRectGetWidth(self.view.bounds) - leading - trailing,
                      CGRectGetHeight(self.view.bounds) - top - bottom);
}

- (void)layoutActiveContainer {
    UIView *container = self.syncContainer ?: self.idleContainer ?: self.asyncContainer;
    if (!container) {
        return;
    }
    container.frame = [self containerFrame];
    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
}

- (void)buildLayoutWithMode:(ZDFlexLayoutAsyncMode)mode {
    [self layoutChrome];
    UIView *container = [[UIView alloc] initWithFrame:[self containerFrame]];
    container.backgroundColor = UIColor.systemGroupedBackgroundColor;
    [self.view addSubview:container];

    // Root flex container
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.padding(YGPointValue(16));
    }];

    // Title label
    UILabel *titleLabel = [self makeLabelWithText:[self titleForMode:mode] fontSize:18 color:UIColor.blackColor];
    [titleLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.marginBottom(YGPointValue(12));
    }];
    [container addChild:titleLabel];

    // Card 1: UILabel measurement
    UIView *card1 = [self makeCardWithTitle:@"UILabel (text measurement)"
                                  content:@"This label demonstrates that text content is correctly measured in async mode without accessing UIKit on the background thread."];
    [container addChild:card1];

    // Card 2: UIImageView measurement
    UIView *card2 = [self makeImageCard];
    [container addChild:card2];

    // Card 3: Custom UIView with sizeThatFits
    UIView *card3 = [self makeCustomViewCard];
    [container addChild:card3];

    // Card 4: Mixed layout with flexGrow
    UIView *card4 = [self makeFlexGrowCard];
    [container addChild:card4];

    // Apply layout with selected mode
    [container.flexLayout applyLayoutWithAsyncMode:mode
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    switch (mode) {
        case ZDFlexLayoutAsyncModeSync:
            self.syncContainer = container;
            break;
        case ZDFlexLayoutAsyncModeRunloopIdle:
            self.idleContainer = container;
            break;
        case ZDFlexLayoutAsyncModeBackgroundThread:
            self.asyncContainer = container;
            break;
    }
}

#pragma mark - Card Builders

- (UIView *)makeCardWithTitle:(NSString *)title content:(NSString *)content {
    UIView *card = UIView.new;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.clipsToBounds = YES;
    [card zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.padding(YGPointValue(12));
        make.marginBottom(YGPointValue(12));
    }];

    UILabel *titleLabel = [self makeLabelWithText:title fontSize:14 color:UIColor.darkGrayColor];
    [titleLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.marginBottom(YGPointValue(6));
    }];
    [card addChild:titleLabel];

    UILabel *contentLabel = [self makeLabelWithText:content fontSize:13 color:UIColor.grayColor];
    contentLabel.numberOfLines = 0;
    [contentLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [card addChild:contentLabel];

    return card;
}

- (UIView *)makeImageCard {
    UIView *card = UIView.new;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.clipsToBounds = YES;
    [card zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.alignItems(YGAlignCenter);
        make.padding(YGPointValue(12));
        make.marginBottom(YGPointValue(12));
    }];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"photo.fill"]];
    imageView.tintColor = UIColor.systemBlueColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(40)).height(YGPointValue(40));
        make.marginRight(YGPointValue(12));
    }];
    [card addChild:imageView];

    UILabel *label = [self makeLabelWithText:@"UIImageView with explicit size (40x40)" fontSize:13 color:UIColor.darkGrayColor];
    [label zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES).flexShrink(1);
    }];
    [card addChild:label];

    return card;
}

- (UIView *)makeCustomViewCard {
    UIView *card = UIView.new;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.clipsToBounds = YES;
    [card zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.padding(YGPointValue(12));
        make.marginBottom(YGPointValue(12));
    }];

    UILabel *titleLabel = [self makeLabelWithText:@"Custom views with sizeThatFits:" fontSize:14 color:UIColor.darkGrayColor];
    [titleLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.marginBottom(YGPointValue(8));
    }];
    [card addChild:titleLabel];

    UISwitch *toggle = UISwitch.new;
    [toggle zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [card addChild:toggle];

    return card;
}

- (UIView *)makeFlexGrowCard {
    UIView *card = UIView.new;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.clipsToBounds = YES;
    [card zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.padding(YGPointValue(8));
        make.marginBottom(YGPointValue(12));
        make.height(YGPointValue(60));
    }];

    NSArray *colors = @[UIColor.systemRedColor, UIColor.systemGreenColor, UIColor.systemBlueColor];
    NSArray *grows = @[@1, @2, @1];

    for (NSInteger i = 0; i < 3; i++) {
        UIView *bar = UIView.new;
        bar.backgroundColor = colors[i];
        bar.layer.cornerRadius = 4;
        CGFloat grow = [grows[i] floatValue];
        [bar zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES);
            make.flexGrow(grow);
            make.marginHorizontal(YGPointValue(4));
        }];
        [card addChild:bar];
    }

    return card;
}

#pragma mark - Helpers

- (UILabel *)makeLabelWithText:(NSString *)text fontSize:(CGFloat)size color:(UIColor *)color {
    UILabel *label = UILabel.new;
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (NSString *)titleForMode:(ZDFlexLayoutAsyncMode)mode {
    switch (mode) {
        case ZDFlexLayoutAsyncModeSync: return @"Mode: Sync (immediate)";
        case ZDFlexLayoutAsyncModeRunloopIdle: return @"Mode: RunLoop Idle";
        case ZDFlexLayoutAsyncModeBackgroundThread: return @"Mode: Background Thread";
    }
}

@end
