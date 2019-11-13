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

- (void)configureFlexLayoutWithBlock:(void (NS_NOESCAPE ^)(ZDFlexLayout * _Nonnull))block {
    if (block) {
        block(self.flexLayout);
    }
}

- (void)addChild:(ZDFlexLayoutView)child {
    if (![child conformsToProtocol:@protocol(ZDFlexLayoutViewProtocol)]) {
        NSCAssert1(NO, @"don't support the type：%@", child);
        return;
    }
    
    [self.children removeObjectIdenticalTo:child];
    [self.children addObject:child];
    child.parent = self;
    
    [self addChildSubviews:child];
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if (![child conformsToProtocol:@protocol(ZDFlexLayoutViewProtocol)]) {
        NSCAssert1(NO, @"不支持移除此类型：%@", child);
        return;
    }
    
    [self.children removeObjectIdenticalTo:child];
    
    if ([child isKindOfClass:UIView.class]) {
        [(UIView *)child removeFromSuperview];
    }
    else {
        [child.children enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZDFlexLayoutView  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [child removeChild:obj];
        }];
    }
    
    child.parent = nil;
}

- (void)addChildren:(NSArray<ZDFlexLayoutView> *)children {
    for (ZDFlexLayoutView view in children) {
        [self addChild:view];
    }
}

- (void)removeChildren:(NSArray<ZDFlexLayoutView> *)children {
    for (ZDFlexLayoutView view in children) {
        [self removeChild:view];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeZero;
}

//MARK: Property
- (void)setOwningView:(UIView *)owningView {
    if (_owningView != owningView) {
        _owningView = owningView;
        
        if (!owningView) {
            return;
        }
        for (ZDFlexLayoutView child in self.children) {
            [self addChildSubviews:child];
        }
    }
}

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

#pragma mark - Private Method

- (void)addChildSubviews:(ZDFlexLayoutView)child {
    if (!child || !_owningView) {
        return;
    }
    
    child.owningView = _owningView;
    
    if ([child isKindOfClass:UIView.class]) {
        [_owningView addSubview:(UIView *)child];
    }
    else {
        for (ZDFlexLayoutView childChild in child.children) {
            childChild.owningView = child.owningView;
            if ([childChild isKindOfClass:UIView.class]) {
                [_owningView addSubview:(UIView *)childChild];
            }
        }
    }
}

@end
