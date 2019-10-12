//
//  UIView+ZDFlexLayout.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "UIView+ZDFlexLayout.h"
#import <objc/runtime.h>
#import "YGLayoutM+Private.h"

@implementation UIView (ZDFlexLayout)

- (BOOL)isYogaEnabled {
    return objc_getAssociatedObject(self, @selector(yoga)) != nil;
}

- (void)configureLayoutWithBlock:(void (^)(YGLayoutM * _Nonnull))block {
    if (block) {
        block(self.yoga);
    }
}

#pragma mark - ZDFlexLayoutNodeProtocol

- (YGLayoutM *)yoga {
    YGLayoutM *yoga = objc_getAssociatedObject(self, _cmd);
    if (!yoga) {
        yoga = [[YGLayoutM alloc] initWithView:self];
        yoga.isEnabled = YES;
        objc_setAssociatedObject(self, _cmd, yoga, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return yoga;
}

- (void)addChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children addObject:child];
    }
    else {
        NSCAssert1(NO, @"不支持此类型：%@", child);
    }
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)] && [self.children containsObject:child]) {
        [self.children removeObject:child];
    }
}

//MARK: Property
- (void)setChildren:(NSArray<ZDFlexLayoutView> *)children {
    objc_setAssociatedObject(self, @selector(children), children, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableOrderedSet<ZDFlexLayoutView> *)children {
    NSMutableOrderedSet<ZDFlexLayoutView> *tempChildren = objc_getAssociatedObject(self, _cmd);
    if (!tempChildren) {
        tempChildren = [NSMutableOrderedSet orderedSet];
        objc_setAssociatedObject(self, _cmd, tempChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tempChildren;
}

- (void)setParent:(ZDFlexLayoutView)parent {
    __weak typeof(parent) weakTarget = parent;
    objc_setAssociatedObject(self, @selector(parent), ^{
        return weakTarget;
    }, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZDFlexLayoutView)parent {
    ZDFlexLayoutView(^block)(void) = objc_getAssociatedObject(self, _cmd);
    ZDFlexLayoutView view = nil;
    if (block) {
        view = block();
    }
    return view;
}

static CGRect YG_UpdateViewFrameIfSuperIsDiv(ZDFlexLayoutView div, CGRect originFrame) {
    // 如果parent是虚拟视图就遍历计算出当前view的真实frame
    if (div.parent && ![div.parent isKindOfClass:UIView.class]) {
        originFrame.origin.x += div.parent.layoutFrame.origin.x;
        originFrame.origin.y += div.parent.layoutFrame.origin.y;
        return YG_UpdateViewFrameIfSuperIsDiv(div.parent, originFrame);
    }
    return originFrame;
}

- (void)setLayoutFrame:(CGRect)layoutFrame {
    self.frame = YG_UpdateViewFrameIfSuperIsDiv(self, layoutFrame);
}

- (CGRect)layoutFrame {
    return self.frame;
}

#pragma mark - 

@end
