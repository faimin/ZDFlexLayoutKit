//
//  NSNotificationCenter+ZDUtility.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (ZDUtility)

/// needn't remove observer again
- (void)zd_addObserverForName:(NSNotificationName)name object:(id)obj queue:(NSOperationQueue *)queue receiver:(id)virtualObserver usingBlock:(void (^)(NSNotification * _Nonnull))block;

@end

NS_ASSUME_NONNULL_END
