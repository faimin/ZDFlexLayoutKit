//
//  UIScrollView+ZDFlexLayout.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "UIScrollView+ZDFlexLayout.h"
#import <objc/runtime.h>
#import "UIView+ZDFlexLayout.h"
#import "ZDFlexLayoutDiv.h"

@implementation UIScrollView (ZDFlexLayout)

- (ZDFlexLayoutView)zd_contentView {
    ZDFlexLayoutDiv *contentDiv = objc_getAssociatedObject(self, @selector(zd_contentView));
    if (!contentDiv) {
        contentDiv = ZDFlexLayoutDiv.new;
        objc_setAssociatedObject(self, @selector(zd_contentView), contentDiv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addChild:contentDiv];
    }
    return contentDiv;
}

- (BOOL)zd_initedContentView {
    return objc_getAssociatedObject(self, @selector(zd_contentView)) != nil;
}

@end
