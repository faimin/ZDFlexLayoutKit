//
//  ZDFlexLayoutViewProtocol.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/11.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#ifndef ZDFlexLayoutViewProtocol_h
#define ZDFlexLayoutViewProtocol_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZDFlexLayoutViewProtocol;
typedef id<ZDFlexLayoutViewProtocol> ZDFlexLayoutView;

@class ZDFlexLayoutCore;
@protocol ZDFlexLayoutViewProtocol <NSObject>

@property (nonatomic, assign, readonly) BOOL isFlexLayoutEnabled;
@property (nonatomic, strong, readonly) ZDFlexLayoutCore *flexLayout;
@property (nonatomic, weak, nullable) UIView *owningView;   ///< real superview
@property (nonatomic, weak, nullable) ZDFlexLayoutView parent;
@property (nonatomic, strong) NSMutableOrderedSet<ZDFlexLayoutView> *children;
@property (nonatomic, assign) CGRect layoutFrame;
@property (nonatomic, assign) BOOL gone;

//=============== autolayout ===============
/// mark the view as root which to calculate frame
@property (nonatomic, assign) BOOL isRoot;
/// mark the rootView need relayout
@property (nonatomic, assign) BOOL isNeedLayoutChildren;

- (void)notifyRootNeedsLayout;
//==========================================

//==========================================
- (void)addChild:(ZDFlexLayoutView)child;
- (void)removeChild:(ZDFlexLayoutView)child;

- (void)addChildren:(NSArray<ZDFlexLayoutView> *)children;
- (void)removeChildren:(NSArray<ZDFlexLayoutView> *)children;

- (void)insertChild:(ZDFlexLayoutView)child atIndex:(NSInteger)index;

- (void)removeFromParent;

- (CGSize)sizeThatFits:(CGSize)size;

- (void)configureFlexLayoutWithBlock:(void(NS_NOESCAPE ^)(ZDFlexLayoutCore *layout))block;

@optional
- (void)needReApplyLayoutAtNextRunloop;

@end

NS_ASSUME_NONNULL_END

#endif /* ZDFlexLayoutViewProtocol_h */
