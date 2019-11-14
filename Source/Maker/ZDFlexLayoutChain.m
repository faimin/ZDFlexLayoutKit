//
//  ZDFlexLayoutChain.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDFlexLayoutChain.h"
#import "UIView+ZDFlexLayout.h"

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
