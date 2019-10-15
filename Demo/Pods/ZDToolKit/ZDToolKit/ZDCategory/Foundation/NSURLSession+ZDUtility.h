//
//  NSURLSession+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/13.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (ZDUtility)

/// 发送同步请求
- (NSData * _Nullable)zd_syncTaskWithRequest:(NSURLRequest *)request error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
