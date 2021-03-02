//
//  WKWebView+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 16/8/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ZDUtility)

/// 获取所有图片链接
- (void)zd_getImageUrls:(void(^)(id imageUrls))block;

/// 禁用长按WKWebView弹出菜单
- (WKUserScript *)zd_disableLongPressScript;

/// 禁用放大缩小手势,在`-webView:didFinishNavigation:`代理方法中注入
+ (NSString *)zd_disablePanGestureScriptString;

@end

NS_ASSUME_NONNULL_END
