//
//  ZDFlexLayoutChain.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDFlexLayoutChain.h"
#import "UIView+ZDFlexLayout.h"

// add this, so we don't have to use `-all_load` or `-force_load` to load object files from static libraries that only contain categories and no classes.
@interface UIView_ZDFlexLayoutChain : NSObject @end
@implementation UIView_ZDFlexLayoutChain @end

@implementation UIView (ZDFlexLayoutChain)

- (instancetype)zd_makeFlexLayout:(void (NS_NOESCAPE ^)(ZDFlexLayoutMaker * _Nonnull))block {
    ZDFlexLayoutMaker *maker = [[ZDFlexLayoutMaker alloc] initWithFlexLayout:self.flexLayout];
    if (block) {
        block(maker);
    }
    return self;
}

@end


@implementation ZDFlexLayoutDiv (ZDFlexLayoutChain)

+ (instancetype)zd_makeFlexLayout:(void (NS_NOESCAPE ^)(ZDFlexLayoutMaker * _Nonnull))block {
    ZDFlexLayoutDiv *div = ZDFlexLayoutDiv.new;
    return [div zd_makeFlexLayout:block];
}

- (instancetype)zd_makeFlexLayout:(void (NS_NOESCAPE ^)(ZDFlexLayoutMaker * _Nonnull))block {
    ZDFlexLayoutMaker *maker = [[ZDFlexLayoutMaker alloc] initWithFlexLayout:self.flexLayout];
    block(maker);
    return self;
}

@end
