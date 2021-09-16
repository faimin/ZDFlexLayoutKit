//
//  NSObject+ZDFlexLayoutFrameCache.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/11/19.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDFlexLayoutFrameCache.h"
#import <objc/runtime.h>
#import "UIView+ZDFlexLayout.h"

// add this, so we don't have to use `-all_load` or `-force_load` to load object files from static libraries that only contain categories and no classes.
@interface UIView_ZDFlexLayoutFrameCache : NSObject @end
@implementation UIView_ZDFlexLayoutFrameCache @end

void ZDCacheViewFlexLayoutFrame(ZDFlexLayoutView view, id *model) {
    NSMutableArray *allCache = @[].mutableCopy;
    __auto_type block = ^void(ZDFlexLayoutView tempView) {
        if (!tempView) {
            return;
        }
        NSMutableArray *tempCache = @[].mutableCopy;
        for (ZDFlexLayoutView child in tempView.children) {
            [tempCache addObject:[NSValue valueWithCGRect:child.layoutFrame]];
        }
        [allCache addObject:tempCache];
    };
    for (ZDFlexLayoutView child in view.children) {
        [allCache addObject:[NSValue valueWithCGRect:child.layoutFrame]];
        block(child);
    }
    
    if (model) {
        ((NSObject *)*model).zd_cachedViewLayoutFrames = allCache;
    }
}

@implementation NSObject (ZDFlexLayoutFrameCache)

- (void)setZd_cachedLayoutFrame:(CGRect)zd_cachedLayoutFrame {
    NSValue *v = [NSValue valueWithCGRect:zd_cachedLayoutFrame];
    objc_setAssociatedObject(self, @selector(zd_cachedLayoutFrame), v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)zd_cachedLayoutFrame {
    CGRect cachedFrame = CGRectZero;
    NSValue *v = objc_getAssociatedObject(self, _cmd);
    if (v) {
        cachedFrame = v.CGRectValue;
    }
    return cachedFrame;
}

- (void)setZd_cachedViewLayoutFrames:(NSArray<NSValue *> *)zd_cachedViewLayoutFrames {
    objc_setAssociatedObject(self, @selector(zd_cachedViewLayoutFrames), zd_cachedViewLayoutFrames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSValue *> *)zd_cachedViewLayoutFrames {
    return objc_getAssociatedObject(self, _cmd);
}

@end
