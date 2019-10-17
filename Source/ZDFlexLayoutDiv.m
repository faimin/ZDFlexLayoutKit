//
//  ZDFlexLayoutDiv.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/11.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDFlexLayoutDiv.h"
#import <objc/runtime.h>
#import "ZDFlexLayout+Private.h"

@implementation ZDFlexLayoutDiv
@synthesize flexLayout = _flexLayout, layoutFrame = _layoutFrame, parent = _parent, children = _children, owningView = _owningView;

#pragma mark - ZDFlexLayoutNodeProtocol

- (BOOL)isFlexLayoutEnabled {
    return _flexLayout != nil;
}

- (void)configureFlexLayoutWithBlock:(void (^)(ZDFlexLayout * _Nonnull))block {
    if (block) {
        block(self.flexLayout);
    }
}

- (void)addChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children removeObjectIdenticalTo:child];
        [self.children addObject:child];
    }
    else {
        NSCAssert1(NO, @"不支持添加此类型：%@", child);
    }
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children removeObjectIdenticalTo:child];
    }
    else {
        NSCAssert1(NO, @"不支持移除此类型：%@", child);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return size;
}

//MARK: Property
- (ZDFlexLayout *)flexLayout {
    if (!_flexLayout) {
        _flexLayout = [[ZDFlexLayout alloc] initWithView:self];
        _flexLayout.isEnabled = YES;
    }
    return _flexLayout;
}

- (NSMutableArray<ZDFlexLayoutView> *)children {
    if (!_children) {
        _children = @[].mutableCopy;
    }
    return _children;
}

@end
