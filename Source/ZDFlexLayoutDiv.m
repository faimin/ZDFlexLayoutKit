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
        [self.flexLayout addSubviewsBaseOnViewHierachy];
    }
}

- (void)addChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children removeObjectIdenticalTo:child];
        [self.children addObject:child];
        child.parent = self;
        
        if ([child isKindOfClass:UIView.class]) {
            [self.owningView addSubview:(UIView *)child];
        }
        else {
            for (ZDFlexLayoutView childChild in child.children) {
                if ([childChild isKindOfClass:UIView.class]) {
                    [self.owningView addSubview:(UIView *)childChild];
                }
            }
        }
    }
    else {
        NSCAssert1(NO, @"don't support the type：%@", child);
    }
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
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
