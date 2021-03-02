//
//  UIViewController+ZDPop.m
//  UINavigationControllerStudy
//
//  Created by Zero on 16/1/25.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIViewController+ZDPop.h"
#import <objc/runtime.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UIViewController_ZDPop)

#pragma mark - key && Function
static void *originDelegateKey = &originDelegateKey;

static void ZD_SwizzlePopInstanceSelector(Class aClass, SEL originalSelector, SEL newSelector) {
    Method origMethod = class_getInstanceMethod(aClass, originalSelector);
    Method newMethod = class_getInstanceMethod(aClass, newSelector);
    
    if (class_addMethod(aClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(aClass, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

#pragma mark - Implementation
@implementation UIViewController (ZDPop)
//do nothing
@end

@implementation UINavigationController (ZDPop)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZD_SwizzlePopInstanceSelector([self class], @selector(viewDidLoad), @selector(zd_viewDidLoad));
        ZD_SwizzlePopInstanceSelector([self class], @selector(navigationBar:shouldPopItem:), @selector(zd_navigationBar:shouldPopItem:));
    });
}

- (void)zd_viewDidLoad {
    [self zd_viewDidLoad];
    
    objc_setAssociatedObject(self, originDelegateKey, self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (BOOL)zd_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    UIViewController *topVC = self.topViewController;
    if (item != topVC.navigationItem) return YES;

    if ([topVC respondsToSelector:@selector(navigationControllerShouldPop:)]) {
        /// 实现此协议方法的控制器要返回NO，这样才能替换系统原来的返回方法
        BOOL systemPop = [(id <UINavigationControllerShouldPop>)topVC navigationControllerShouldPop:self];
        if (systemPop) {
            return [self zd_navigationBar:navigationBar shouldPopItem:item];
        }
        else {
            return NO;
        }
    }
    else {
        return [self zd_navigationBar:navigationBar shouldPopItem:item];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        UIViewController *topVC = self.topViewController;
        if ([topVC respondsToSelector:@selector(navigationControllerShouldStarInteractivePopGestureRecognizer:)]) {
#if MergeGestureToBackMethod
            if (![(id<UINavigationControllerShouldPop>)topVC navigationControllerShouldPop:self]) {
                return NO;
            }
#else
            if ([(id<UINavigationControllerShouldPop>)vc navigationControllerShouldStarInteractivePopGestureRecognizer:self]) {
                return NO;
            }
#endif
        }
        id<UIGestureRecognizerDelegate> originDelegate = objc_getAssociatedObject(self, originDelegateKey);
        return [originDelegate gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originDelegeate = objc_getAssociatedObject(self, originDelegateKey);
        return [originDelegeate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originDelegeate = objc_getAssociatedObject(self, originDelegateKey);
        return [originDelegeate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return YES;
}

@end

