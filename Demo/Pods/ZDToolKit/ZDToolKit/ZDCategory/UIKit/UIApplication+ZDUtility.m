//
//  UIApplication+ZDUtility.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/1/14.
//

#import "UIApplication+ZDUtility.h"

typedef void(^__ZDResponderCallBack)(UIResponder *);

@interface UIResponder (__ZDPrivate)
- (void)_zd_reportAsFirst:(__ZDResponderCallBack)sender;
@end

@implementation UIApplication (ZDUtility)

// https://www.appcoda.com.tw/first-responder
- (__kindof UIResponder *)zd_firstResponder {
    __block __kindof UIResponder *firstResponder = nil;
    __ZDResponderCallBack sender = ^void(UIResponder *responder){
        firstResponder = responder;
    };
    // 原理：to(target)为nil时会自动传递给第一响应者
    [self sendAction:@selector(_zd_reportAsFirst:) to:nil from:sender forEvent:nil];
    return firstResponder;
}

@end

@implementation UIResponder (__ZDPrivate)

- (void)_zd_reportAsFirst:(__ZDResponderCallBack)sender {
    if (sender) sender(self);
}

@end
