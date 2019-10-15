//
//  WKWebView+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 16/8/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "WKWebView+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(WKWebView_ZDUtility)

@implementation WKWebView (ZDUtility)

/// 获取所有图片链接
- (void)zd_getImageUrls:(void(^)(id _Nullable imageUrls))block {
    static NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [self evaluateJavaScript:jsGetImages completionHandler:nil];
    [self evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (result) {
            block(result);
        } else {
            block(error);
        }
    }];
}

/// 禁用长按WKWebView弹出菜单
- (WKUserScript *)zd_disableLongPressScript {
    NSString *source = @"var style = document.createElement('style'); \
    style.type = 'text/css'; \
    style.innerText = '*:not(input):not(textarea) { -webkit-user-select: none; -webkit-touch-callout: none; }'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(style);";
    
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    return script;
}

/// 禁用放大缩小手势,在`-webView:didFinishNavigation:`代理方法中注入
+ (NSString *)zd_disablePanGestureScriptString {
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    return injectionJSString;
}

@end
