//
//  ZDFlexLayoutMaker.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDFlexLayoutCore.h"
#import "ZDFlexLayoutViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define ZD_CHAIN_NORMAL_PROPERTY(TYPE, PROPERTY_NAME) \
- (ZDFlexLayoutMaker *(^)(TYPE PROPERTY_NAME))PROPERTY_NAME;

@interface ZDFlexLayoutMaker : NSObject
     
- (instancetype)initWithFlexLayout:(ZDFlexLayoutCore *)flexLayout;

ZD_CHAIN_NORMAL_PROPERTY(BOOL, isEnabled)
ZD_CHAIN_NORMAL_PROPERTY(BOOL, isIncludedInLayout)

ZD_CHAIN_NORMAL_PROPERTY(YGDirection, direction)
ZD_CHAIN_NORMAL_PROPERTY(YGFlexDirection, flexDirection)
ZD_CHAIN_NORMAL_PROPERTY(YGJustify, justifyContent)
ZD_CHAIN_NORMAL_PROPERTY(YGAlign, alignContent)
ZD_CHAIN_NORMAL_PROPERTY(YGAlign, alignItems)
ZD_CHAIN_NORMAL_PROPERTY(YGAlign, alignSelf)
ZD_CHAIN_NORMAL_PROPERTY(YGPositionType, position)
ZD_CHAIN_NORMAL_PROPERTY(YGWrap, flexWrap)
ZD_CHAIN_NORMAL_PROPERTY(YGOverflow, overflow)
ZD_CHAIN_NORMAL_PROPERTY(YGDisplay, display)

ZD_CHAIN_NORMAL_PROPERTY(CGFloat, flex)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, flexGrow)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, flexShrink)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, flexBasis)

ZD_CHAIN_NORMAL_PROPERTY(YGValue, left)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, top)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, right)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, bottom)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, start)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, end)

ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginLeft)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginTop)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginRight)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginBottom)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginStart)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginEnd)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginHorizontal)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, marginVertical)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, margin)

ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingLeft)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingTop)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingRight)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingBottom)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingStart)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingEnd)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingHorizontal)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, paddingVertical)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, padding)

ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderLeftWidth)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderTopWidth)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderRightWidth)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderBottomWidth)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderStartWidth)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderEndWidth)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, borderWidth)

ZD_CHAIN_NORMAL_PROPERTY(YGValue, width)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, height)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, minWidth)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, minHeight)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, maxWidth)
ZD_CHAIN_NORMAL_PROPERTY(YGValue, maxHeight)
ZD_CHAIN_NORMAL_PROPERTY(CGFloat, aspectRatio)

- (ZDFlexLayoutMaker *(^)(void))markDirty;

- (ZDFlexLayoutMaker *(^)(BOOL))gone;

- (ZDFlexLayoutMaker *(^)(NSArray<ZDFlexLayoutView> *))addChildren;

#pragma mark - Unavailable

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
