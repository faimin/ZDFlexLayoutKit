//
//  UIControl+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
/*
 http://www.tuicool.com/articles/fMRv6jz
 http://blog.csdn.net/uxyheaven/article/details/48009197
 */

#import "UIControl+ZDUtility.h"
#import <objc/runtime.h>

static void SwizzleInstanceMethod(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static BOOL _isIgnoreEvent = NO;

@interface ZDControlWrap : NSObject

@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, copy) void(^block)(id sender);

- (instancetype)initWithBlock:(void(^)(id sender))block forControlEvents:(UIControlEvents)controlEvents;

@end

@implementation ZDControlWrap

- (instancetype)initWithBlock:(void (^)(id sender))block forControlEvents:(UIControlEvents)controlEvents {
    self = [super init];
    if (self) {
        self.block = block;
        self.controlEvents = controlEvents;
    }
    return self;
}

- (void)zd_execute:(id)sender {
    if (self.block) {
        self.block(sender);
    }
}

@end

/// =======================================================

@implementation UIControl (ZDUtility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod(self, @selector(sendAction:to:forEvent:), @selector(zd_sendAction:to:forEvent:));
    });
}

- (void)zd_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (_isIgnoreEvent) {
        return;
    }
    else if (self.zd_clickIntervalTime > 0) {
        _isIgnoreEvent = YES;
        //超过时间间隔后恢复
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.zd_clickIntervalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isIgnoreEvent = NO;
        });
        [self zd_sendAction:action to:target forEvent:event];
    }
    else {
        [self zd_sendAction:action to:target forEvent:event];
    }
}

- (void)setZd_clickIntervalTime:(NSTimeInterval)clickIntervalTime {
    objc_setAssociatedObject(self, @selector(zd_clickIntervalTime), @(clickIntervalTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)zd_clickIntervalTime {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

#pragma mark

- (void)zd_addBlockForControlEvents:(UIControlEvents)controlEvents block:(void(^)(id sender))block {
    ZDControlWrap *zdControl = [[ZDControlWrap alloc] initWithBlock:block forControlEvents:controlEvents];
    [self addTarget:zdControl action:@selector(zd_execute:) forControlEvents:controlEvents];
}

@end



