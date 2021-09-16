//
//  UIView+ZDFlexLayoutCore.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "UIView+ZDFlexLayout.h"
#import <objc/runtime.h>
#import "ZDFlexLayoutCore+Private.h"
#import "ZDFlexLayoutDiv.h"
#import "ZDCalculateHelper.h"
#import "NSObject+ZDFLDeallocCallback.h"

// add this, so we don't have to use `-all_load` or `-force_load` to load object files from static libraries that only contain categories and no classes.
@interface UIView_ZDFlexLayout : NSObject @end
@implementation UIView_ZDFlexLayout @end

@implementation UIView (ZDFlexLayout)

- (void)markDirty {
    [self.flexLayout markDirty];
    [self notifyRootNeedsLayout];
}

- (void)calculateLayoutPreservingOrigin:(BOOL)preserveOrigin {
    [self calculateLayoutWithAutoRefresh:NO preservingOrigin:preserveOrigin];
}

- (void)calculateLayoutWithAutoRefresh:(BOOL)autoRefresh preservingOrigin:(BOOL)preserveOrigin {
    [self calculateLayoutWithAutoRefresh:autoRefresh preservingOrigin:preserveOrigin dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];
}

- (void)calculateLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility {
    [self calculateLayoutWithAutoRefresh:NO preservingOrigin:preserveOrigin dimensionFlexibility:dimensionFlexibility];
}

- (void)calculateLayoutWithAutoRefresh:(BOOL)autoRefresh preservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility {
    [self.flexLayout applyLayoutPreservingOrigin:preserveOrigin dimensionFlexibility:dimensionFlexibility];
    
    if (!autoRefresh) {
        return;
    }
    
    self.isRoot = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_block_t calculateTask = ^{
        if (weakSelf.isNeedLayoutChildren) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.flexLayout applyLayoutPreservingOrigin:YES dimensionFlexibility:dimensionFlexibility];
            });
            weakSelf.isNeedLayoutChildren = NO;
        }
    };
    [self zdfl_deallocBlock:^(id  _Nonnull realTarget) {
        [ZDCalculateHelper removeAsyncLayoutTask:calculateTask];
    }];
    [ZDCalculateHelper asyncLayoutTask:calculateTask];
}

- (void)asyncCalculateLayoutPreservingOrigin:(BOOL)preserveOrigin {    
    [self asyncCalculateLayoutPreservingOrigin:preserveOrigin dimensionFlexibility:0];
}

- (void)asyncCalculateLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility {
    [self.flexLayout asyncApplyLayout:YES preservingOrigin:preserveOrigin dimensionFlexibility:dimensionFlexibility];
}

#pragma mark - ZDFlexLayoutNodeProtocol

- (BOOL)isFlexLayoutEnabled {
    ZDFlexLayoutCore *flexLayout = objc_getAssociatedObject(self, @selector(flexLayout));
    if (!flexLayout) {
        return NO;
    }
    return flexLayout.isEnabled;
}

- (void)configureFlexLayoutWithBlock:(void (NS_NOESCAPE ^)(ZDFlexLayoutCore * _Nonnull))block {
    if (block) {
        block(self.flexLayout);
    }
}

- (ZDFlexLayoutCore *)flexLayout {
    ZDFlexLayoutCore *layout = objc_getAssociatedObject(self, _cmd);
    if (!layout) {
        layout = [[ZDFlexLayoutCore alloc] initWithView:self];
        layout.isEnabled = NO;
        objc_setAssociatedObject(self, _cmd, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layout;
}

- (void)addChild:(ZDFlexLayoutView)child {
    if (![child conformsToProtocol:@protocol(ZDFlexLayoutViewProtocol)]) {
        NSCAssert1(NO, @"don't support the type：%@", child);
        return;
    }
    
    // make sure to enable flexlayout
    if (!child.isFlexLayoutEnabled) {
        child.flexLayout.isEnabled = YES;
    }
    
    [self.children removeObject:child];
    [self.children addObject:child];
    child.parent = self;
    child.owningView = self;
    
    if ([child isKindOfClass:UIView.class]) {
        [self addSubview:(UIView *)child];
    }
    else {
        for (ZDFlexLayoutView childChild in child.children) {
            childChild.owningView = self;
            if ([childChild isKindOfClass:UIView.class]) {
                [self addSubview:(UIView *)childChild];
            }
        }
    }
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if (![child conformsToProtocol:@protocol(ZDFlexLayoutViewProtocol)]) {
        NSCAssert1(NO, @"don't support the type：%@", child);
        return;
    }
    
    if (![self.children containsObject:child]) {
        return;
    }
    
    [self.children removeObject:child];
    
    if ([child isKindOfClass:UIView.class]) {
        [(UIView *)child removeFromSuperview];
    }
    else {
        [child.children enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZDFlexLayoutView  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [child removeChild:obj];
        }];
    }
    
    child.parent = nil;
    child.owningView = nil;
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

- (void)insertChild:(ZDFlexLayoutView)child atIndex:(NSInteger)index {
    if (![child conformsToProtocol:@protocol(ZDFlexLayoutViewProtocol)]) {
        NSCAssert1(NO, @"don't support the type：%@", child);
        return;
    }
    
    [self.children removeObject:child];
    NSInteger mapedIndex = index; // realIndex
    if (index > self.children.count || index < 0) {
        mapedIndex = self.children.count;
    }
    [self.children insertObject:child atIndex:mapedIndex];
    child.parent = self;
    child.owningView = self;
    
    if ([child isKindOfClass:UIView.class]) {
        [self insertSubview:(UIView *)child atIndex:mapedIndex];
    }
    else {
        for (ZDFlexLayoutView childChild in child.children) {
            childChild.owningView = self;
            if ([childChild isKindOfClass:UIView.class]) {
                [self insertSubview:(UIView *)childChild atIndex:mapedIndex++];
            }
        }
    }
}

- (void)removeFromParent {
    if (self.parent) {
        [self.parent removeChild:self];
    }
}

- (void)notifyRootNeedsLayout {
    if (self.isRoot && self.isNeedLayoutChildren) {
        return;
    }
    
    if (self.isRoot && !self.isNeedLayoutChildren) {
        self.isNeedLayoutChildren = YES;
    }
    else if (!self.isRoot && self.parent) {
        [self.parent notifyRootNeedsLayout];
    }
}

//MARK: Property
- (void)setChildren:(NSMutableOrderedSet<ZDFlexLayoutView> *)children {
    objc_setAssociatedObject(self, @selector(children), children, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableOrderedSet<ZDFlexLayoutView> *)children {
    NSMutableOrderedSet<ZDFlexLayoutView> *tempChildren = objc_getAssociatedObject(self, _cmd);
    if (!tempChildren) {
        tempChildren = [[NSMutableOrderedSet<ZDFlexLayoutView> alloc] init];
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

static CGRect ZD_UpdateFrameIfSuperViewIsDiv(ZDFlexLayoutView div, CGRect originFrame) {
    // 如果parent是虚拟视图就遍历计算出当前view的真实frame
    if (div.parent && ![div.parent isKindOfClass:UIView.class]) {
        originFrame.origin.x += div.parent.layoutFrame.origin.x;
        originFrame.origin.y += div.parent.layoutFrame.origin.y;
        return ZD_UpdateFrameIfSuperViewIsDiv(div.parent, originFrame);
    }
    return originFrame;
}

- (void)setLayoutFrame:(CGRect)layoutFrame {
    self.frame = ZD_UpdateFrameIfSuperViewIsDiv(self, layoutFrame);
}

- (CGRect)layoutFrame {
    return self.frame;
}

- (void)setGone:(BOOL)gone {
    self.flexLayout.isIncludedInLayout = !gone;
    self.hidden = gone;
    objc_setAssociatedObject(self, @selector(gone), @(gone), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self markDirty];
}

- (BOOL)gone {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsRoot:(BOOL)isRoot {
    objc_setAssociatedObject(self, @selector(isRoot), @(isRoot), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isRoot {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsNeedLayoutChildren:(BOOL)isNeedLayoutChildren {
    objc_setAssociatedObject(self, @selector(isNeedLayoutChildren), @(isNeedLayoutChildren), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isNeedLayoutChildren {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

#pragma mark - Override (UILabel)

#if CGFLOAT_IS_DOUBLE
    #define ZDCEIL ceil
#else
    #define ZDCEIL ceilf
#endif

@implementation UILabel (ZDFlexLayout)

// Fix the accuracy problem (精度缺失导致label中的文字截断问题)
- (void)setLayoutFrame:(CGRect)layoutFrame {
    CGRect tmpFrame = layoutFrame;
    tmpFrame.size.width = ZDCEIL(CGRectGetWidth(layoutFrame));
    tmpFrame.size.height = ZDCEIL(CGRectGetHeight(layoutFrame));
    [super setLayoutFrame:tmpFrame];
}

@end

#pragma mark - UIScrollView ZDFlexLayout

@interface UIScrollView ()

@property (nonatomic, assign) BOOL zd_needRelayout;

@end

@implementation UIScrollView (ZDFlexLayout)

- (BOOL)zd_initedContentView {
    return objc_getAssociatedObject(self, @selector(zd_contentView)) != nil;
}

- (void)zd_setNeedReLayoutAtNextRunloop:(BOOL)relayout {
    self.zd_needRelayout = relayout;
}

- (void)needReApplyLayoutAtNextRunloop {
    if (!self.zd_initedContentView) {
        return;
    }
    
    self.contentSize = self.zd_contentView.layoutFrame.size;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!objc_getAssociatedObject(self, @selector(zd_needRelayout)) || self.zd_needRelayout) {
            self.zd_needRelayout = NO;
            [self.owningView setNeedsLayout];
            [self.owningView layoutIfNeeded];
            [self.owningView.flexLayout applyLayoutPreservingOrigin:YES];
        }
    });
}

#pragma mark - Property

- (ZDFlexLayoutDiv *)zd_contentView {
    ZDFlexLayoutDiv *contentDiv = objc_getAssociatedObject(self, _cmd);
    if (!contentDiv) {
        contentDiv = ZDFlexLayoutDiv.new;
        objc_setAssociatedObject(self, _cmd, contentDiv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addChild:contentDiv];
    }
    return contentDiv;
}

- (void)setZd_needRelayout:(BOOL)zd_needRelayout {
    objc_setAssociatedObject(self, @selector(zd_needRelayout), @(zd_needRelayout), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)zd_needRelayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
