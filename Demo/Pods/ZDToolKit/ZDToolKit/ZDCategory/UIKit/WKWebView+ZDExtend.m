//
//  WKWebView+ZDExtend.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 16/8/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "WKWebView+ZDExtend.h"

@implementation WKWebView (ZDExtend)

///  获取所有图片链接
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

@end
