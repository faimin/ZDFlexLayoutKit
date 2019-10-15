//
//  UIViewController+ZDPop.h
//  UINavigationControllerStudy
//
//  Created by Zero on 16/1/25.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//  refer： http://www.jianshu.com/p/6376149a2c4c

#import <UIKit/UIKit.h>

#define MergeGestureToBackMethod 1  ///< 是否把手势返回也放入第一个协议方法里

#pragma mark - Protocol
@protocol UINavigationControllerShouldPop <NSObject>
@optional
- (BOOL)navigationControllerShouldPop:(UINavigationController *)navigatonController;
- (BOOL)navigationControllerShouldStarInteractivePopGestureRecognizer:(UINavigationController *)navigatonController;
@end

#pragma mark - Category
@interface UIViewController (ZDPop)<UINavigationControllerShouldPop, UIGestureRecognizerDelegate>

@end

