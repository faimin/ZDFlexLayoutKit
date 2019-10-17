//
//  UIView+ZDFlexLayout.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "UIView+ZDFlexLayout.h"
#import <objc/runtime.h>
#import "ZDFlexLayout+Private.h"

@implementation UIView (ZDFlexLayout)

#pragma mark - ZDFlexLayoutNodeProtocol

- (BOOL)isFlexLayoutEnabled {
    return objc_getAssociatedObject(self, @selector(flexLayout)) != nil;
}

- (void)configureFlexLayoutWithBlock:(void (^)(ZDFlexLayout * _Nonnull))block {
    if (block) {
        block(self.flexLayout);
    }
}

- (ZDFlexLayout *)flexLayout {
    ZDFlexLayout *layout = objc_getAssociatedObject(self, _cmd);
    if (!layout) {
        layout = [[ZDFlexLayout alloc] initWithView:self];
        layout.isEnabled = YES;
        objc_setAssociatedObject(self, _cmd, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layout;
}

- (void)addChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children removeObjectIdenticalTo:child];
        [self.children addObject:child];
        child.owningView = self;
    }
    else {
        NSCAssert1(NO, @"不支持此类型：%@", child);
    }
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children removeObjectIdenticalTo:child];
        child.owningView = nil;
    }
}

//MARK: Property
- (void)setChildren:(NSArray<ZDFlexLayoutView> *)children {
    objc_setAssociatedObject(self, @selector(children), children, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<ZDFlexLayoutView> *)children {
    NSMutableArray<ZDFlexLayoutView> *tempChildren = objc_getAssociatedObject(self, _cmd);
    if (!tempChildren) {
        tempChildren = @[].mutableCopy;
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

- (void)setOwningView:(UIView *)owningView {
    __weak typeof(owningView) weakTarget = owningView;
    objc_setAssociatedObject(self, @selector(owningView), ^{
        return weakTarget;
    }, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)owningView {
    UIView *(^block)(void) = objc_getAssociatedObject(self, _cmd);
    UIView *view = nil;
    if (block) {
        view = block();
    }
    return view;
}

- (void)setLayoutFrame:(CGRect)layoutFrame {
    self.frame = YG_UpdateViewFrameIfSuperIsDiv(self, layoutFrame);
    NSLog(@"%@'s frame = %@", NSStringFromClass(self.class), NSStringFromCGRect(self.frame));
}

- (CGRect)layoutFrame {
    return self.frame;
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

@end
