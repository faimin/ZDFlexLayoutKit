//
//  WKWebView+ZDExtend.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 16/8/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ZDExtend)

- (void)zd_getImageUrls:(void(^)(id imageUrls))block;

@end

NS_ASSUME_NONNULL_END
