//
//  UIViewController+ZDUtility.m
//  ZDUtility
//
//  Created by Zero on 16/1/16.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIViewController+ZDUtility.h"


@implementation UIViewController (ZDUtility)

- (BOOL)zd_isSupport3DTouch {
    if (@available(iOS 9.0, *)) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)zd_isComefromPresent {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        BOOL isPresent = (self.presentationController != nil);
        return isPresent;
    }
    else {
        if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] > 0) {
            return NO;
        }
        if (self.presentingViewController) {
            return YES;
        }
        return NO;
    }
}

- (UIScreenEdgePanGestureRecognizer *)zd_screenEdgePanGesture {
    if (!self.navigationController) return nil;
    
    UIScreenEdgePanGestureRecognizer *edgePanGesture = nil;
    
    NSArray *gestures = self.navigationController.view.gestureRecognizers;
    for (__kindof UIGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            edgePanGesture = gesture;
            break;
        }
    }
    
    return edgePanGesture;
}

- (void)zd_popOrDismiss {
    if (self.presentationController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)zd_presentModalBuyItemVCWithId:(NSString *)itemId animated:(BOOL)animated {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        SKStoreProductViewController *skvc = [[SKStoreProductViewController alloc] init];
        skvc.delegate = self;
        [skvc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : itemId} completionBlock:^(BOOL result, NSError *error){
            if (!result || error) {
                [skvc dismissViewControllerAnimated:YES completion:nil];
                UIApplication *application = [UIApplication sharedApplication];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", itemId]];
                /// options目前可传入参数Key在UIApplication头文件只有一个:UIApplicationOpenURLOptionUniversalLinksOnly,其对应的Value为布尔值,默认为False.如该Key对应的Value为True,那么打开所传入的Universal Link时,只允许通过这个Link所代表的iOS应用跳转的方式打开这个链接,否则就会返回success为false,也就是说只有安装了Link所对应的App的情况下才能打开这个Universal Link,而不是通过启动Safari方式打开这个Link的代表的网站.
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url
                                                       options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO}
                                             completionHandler:^(BOOL success) {
                                                 NSLog(@"Open sucess: %d", success);
                                             }];
                }
                else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [application openURL:url];
#pragma clang diagnostic pop
                }
            }
        }];
        [self presentViewController:skvc animated:YES completion:nil];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", itemId]]];
#pragma clang diagnostic pop
    }
}

- (void)zd_productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

// reference: http://stackoverflow.com/questions/19140530/toplayoutguide-in-child-view-controller
- (id<UILayoutSupport>)zd_navigationBarTopLayoutGuide {
    if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        return self.parentViewController.zd_navigationBarTopLayoutGuide;
    }
    else {
        return self.topLayoutGuide;
    }
}

- (id<UILayoutSupport>)zd_navigationBarBottomLayoutGuide {
    if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        return self.parentViewController.zd_navigationBarBottomLayoutGuide;
    }
    else {
        return self.topLayoutGuide;
    }
}

@end
