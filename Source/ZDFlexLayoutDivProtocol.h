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

@protocol ZDFlexLayoutDivProtocol;
typedef id<ZDFlexLayoutDivProtocol> ZDFlexLayoutView;

@class YGLayoutM;
@protocol ZDFlexLayoutDivProtocol <NSObject>

@property (nonatomic, strong, readonly) YGLayoutM *yoga;
@property (nonatomic, weak) ZDFlexLayoutView parent;
@property (nonatomic, strong) NSMutableOrderedSet<ZDFlexLayoutView> *children;
@property (nonatomic, assign) CGRect layoutFrame;

- (void)addChild:(ZDFlexLayoutView)child;
- (void)removeChild:(ZDFlexLayoutView)child;

- (CGSize)sizeThatFits:(CGSize)size;

@end

#endif /* ZDFlexLayoutDivProtocol_h */
