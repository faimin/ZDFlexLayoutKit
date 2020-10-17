//
//  NSMutableArray+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/4.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (ZDUtility)

+ (id)zd_mutableArrayUsingWeakReferences;

+ (id)zd_mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end

NS_ASSUME_NONNULL_END
