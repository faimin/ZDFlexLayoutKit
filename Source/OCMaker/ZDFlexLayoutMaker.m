//
//  ZDFlexLayoutMaker.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDFlexLayoutMaker.h"

#define ZD_CHAIN_NORMAL_PROPERTY_IMP(TYPE, PROPERTY_NAME)   \
- (ZDFlexLayoutMaker *(^)(TYPE))PROPERTY_NAME {             \
    return ^ZDFlexLayoutMaker *(TYPE x) {                   \
        self.flexLayout.PROPERTY_NAME = x;                  \
        return self;                                        \
    };                                                      \
}

@interface ZDFlexLayoutMaker ()
@property (nonatomic, weak) ZDFlexLayoutCore *flexLayout;
@end

@implementation ZDFlexLayoutMaker

- (instancetype)initWithFlexLayout:(ZDFlexLayoutCore *)flexLayout {
    if (self = [super init]) {
        flexLayout.isEnabled = YES;
        _flexLayout = flexLayout;
    }
    return self;
}

ZD_CHAIN_NORMAL_PROPERTY_IMP(BOOL, isEnabled)
ZD_CHAIN_NORMAL_PROPERTY_IMP(BOOL, isIncludedInLayout)

ZD_CHAIN_NORMAL_PROPERTY_IMP(YGDirection, direction)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGFlexDirection, flexDirection)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGJustify, justifyContent)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGAlign, alignContent)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGAlign, alignItems)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGAlign, alignSelf)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGPositionType, position)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGWrap, flexWrap)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGOverflow, overflow)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGDisplay, display)

ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, flex)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, flexGrow)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, flexShrink)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, flexBasis)

ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, left)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, top)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, right)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, bottom)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, start)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, end)

ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginLeft)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginTop)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginRight)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginBottom)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginStart)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginEnd)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginHorizontal)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, marginVertical)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, margin)

ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingLeft)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingTop)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingRight)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingBottom)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingStart)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingEnd)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingHorizontal)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, paddingVertical)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, padding)

ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderLeftWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderTopWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderRightWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderBottomWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderStartWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderEndWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, borderWidth)

ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, width)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, height)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, minWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, minHeight)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, maxWidth)
ZD_CHAIN_NORMAL_PROPERTY_IMP(YGValue, maxHeight)
ZD_CHAIN_NORMAL_PROPERTY_IMP(CGFloat, aspectRatio)

- (ZDFlexLayoutMaker *(^)(void))markDirty {
    return ^ZDFlexLayoutMaker *(void) {
        [self.flexLayout markDirty];
        [self.flexLayout.view notifyRootNeedsLayout];
        return self;
    };
}

- (ZDFlexLayoutMaker *(^)(BOOL))gone {
    return ^ZDFlexLayoutMaker *(BOOL gone) {
        self.flexLayout.view.gone = gone;
        return self;
    };
}

- (ZDFlexLayoutMaker *(^)(NSArray<ZDFlexLayoutView> *))addChildren {
    return ^ZDFlexLayoutMaker *(NSArray<ZDFlexLayoutView> *children) {
        if (children.count > 0) {
            [self.flexLayout.view addChildren:children];
        }
        return self;
    };
}

@end
