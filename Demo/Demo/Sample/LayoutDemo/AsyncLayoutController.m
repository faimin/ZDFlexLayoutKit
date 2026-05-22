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

@end

@implementation AsyncLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Async Layout Demo";
    self.view.backgroundColor = UIColor.whiteColor;

    [self setupModeSelector];
    [self buildLayoutWithMode:ZDFlexLayoutAsyncModeSync];
}

#pragma mark - Mode Selector

- (void)setupModeSelector {
    self.modeSegment = [[UISegmentedControl alloc] initWithItems:@[@"Sync", @"RunLoop Idle", @"Background Thread"]];
    self.modeSegment.selectedSegmentIndex = 0;
    [self.modeSegment addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    self.modeSegment.frame = CGRectMake(20, 120, self.view.bounds.size.width - 40, 36);
    [self.view addSubview:self.modeSegment];
}

- (void)modeChanged:(UISegmentedControl *)sender {
    [self clearLayout];
    ZDFlexLayoutAsyncMode mode;
    switch (sender.selectedSegmentIndex) {
        case 0: mode = ZDFlexLayoutAsyncModeSync; break;
        case 1: mode = ZDFlexLayoutAsyncModeRunloopIdle; break;
        case 2: mode = ZDFlexLayoutAsyncModeBackgroundThread; break;
        default: mode = ZDFlexLayoutAsyncModeSync; break;
    }
    [self buildLayoutWithMode:mode];
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

- (void)buildLayoutWithMode:(ZDFlexLayoutAsyncMode)mode {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 160, self.view.bounds.size.width, self.view.bounds.size.height - 160)];
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
