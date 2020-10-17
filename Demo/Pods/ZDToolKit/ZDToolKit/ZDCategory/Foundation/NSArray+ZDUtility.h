//
//  NSArray+ZDUtility.h
//  ZDUtility
//
//  Created by Zero on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (ZDUtility)

- (nullable ObjectType)zd_anyObject;

/// 反转数组中元素的顺序
- (NSArray<ObjectType> *)zd_reverse;

/// 打乱数组中元素的原有顺序
- (__kindof NSArray<ObjectType> *)zd_shuffle;

/// 把某一元素移动到最前面
- (__kindof NSArray<ObjectType> *)zd_moveObjcToFront:(ObjectType)objc;

/// 去重
- (NSArray<ObjectType> *)zd_deduplication;

/// 获取两个数组中的相同元素
- (NSArray *)zd_collectSameElementWithArray:(__kindof NSArray *)otherArray;

/// 求和
- (CGFloat)zd_sum;
/// 平均值
- (CGFloat)zd_avg;
/// 最大值
- (CGFloat)zd_max;
/// 最小值
- (CGFloat)zd_min;

- (NSMutableArray *)zd_map:(id (^)(ObjectType objc))block;
- (NSMutableArray<ObjectType> *)zd_filter:(BOOL (^)(ObjectType objc))block;
- (NSMutableArray<ObjectType> *)zd_flatten;
- (NSMutableArray<ObjectType> *)zd_zipWith:(NSArray<ObjectType> *)rightArray usingBlock:(id(^)(ObjectType left, ObjectType right))block;
- (NSMutableArray<ObjectType> *)zd_mutableArray;

@end

NS_ASSUME_NONNULL_END
