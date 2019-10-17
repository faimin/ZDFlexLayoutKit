//
//  ZDFlexLayoutDivProtocol.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/11.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#ifndef ZDFlexLayoutDivProtocol_h
#define ZDFlexLayoutDivProtocol_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZDFlexLayoutDivProtocol;
typedef id<ZDFlexLayoutDivProtocol> ZDFlexLayoutView;

@class ZDFlexLayout;
@protocol ZDFlexLayoutDivProtocol <NSObject>

@property (nonatomic, assign, readonly) BOOL isFlexLayoutEnabled;
@property (nonatomic, strong, readonly) ZDFlexLayout *flexLayout;
@property (nonatomic, weak, nullable) ZDFlexLayoutView parent;
@property (nonatomic, weak, nullable) UIView *owningView;                   ///< 持有自己的视图
@property (nonatomic, strong) NSMutableArray<ZDFlexLayoutView> *children;
@property (nonatomic, assign) CGRect layoutFrame;

- (void)addChild:(ZDFlexLayoutView)child;
- (void)removeChild:(ZDFlexLayoutView)child;

- (CGSize)sizeThatFits:(CGSize)size;

/**
In ObjC land, every time you access `view.yoga.*` you are adding another `objc_msgSend`
to your code. If you plan on making multiple changes to YGLayout, it's more performant
to use this method, which uses a single objc_msgSend call.
*/
- (void)configureFlexLayoutWithBlock:(void(^)(ZDFlexLayout *layout))block;

@end

NS_ASSUME_NONNULL_END

#endif /* ZDFlexLayoutDivProtocol_h */
