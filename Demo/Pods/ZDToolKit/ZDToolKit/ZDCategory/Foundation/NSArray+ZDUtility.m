//
//  NSArray+ZDExtend.m
//  ZDUtility
//
//  Created by Zero on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSArray+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSArray_ZDUtility)

@implementation NSArray (ZDUtility)

- (id)zd_anyObject {
    if (self.count == 0) return nil;
    
    NSUInteger index = arc4random_uniform((uint32_t)self.count);
    return self[index];
}

- (NSArray *)zd_reverse {
    if (self.count <= 1) {
        return self;
    }
    return [self reverseObjectEnumerator].allObjects;
}

- (NSMutableArray *)zd_shuffle {
    NSMutableArray *mutArr = [self isKindOfClass:[NSMutableArray class]] ? self : [self mutableCopy];
    if (self.count > 0) {
        for (NSUInteger i = self.count; i > 1; i--) {
            [mutArr exchangeObjectAtIndex:(i - 1)
                      withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
    }
    return mutArr;
}

- (NSMutableArray *)zd_moveObjcToFront:(id)obj {
    NSMutableArray *mutArr = [self isKindOfClass:[NSMutableArray class]] ? self : [self mutableCopy];
    if ([mutArr containsObject:obj]) {
        [mutArr removeObject:obj];
        [mutArr insertObject:obj atIndex:0];
    }
    return mutArr;
}

- (NSArray *)zd_deduplication {
#if 1
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueCoding/CollectionOperators.html
    return [self valueForKeyPath:@"@distinctUnionOfObjects.self"];
#else
    return [NSSet setWithArray:self].allObjects;
#endif
}

- (NSArray *)zd_collectSameElementWithArray:(NSArray *)otherArray {
    if (!otherArray || otherArray.count == 0) return @[];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", otherArray];
    NSArray *sameElements = [self filteredArrayUsingPredicate:predicate];
    return sameElements;
}

- (CGFloat)zd_sum {
    return [[self valueForKeyPath:@"@sum.floatValue"] floatValue];
}

- (CGFloat)zd_avg {
    return [[self valueForKeyPath:@"@avg.floatValue"] floatValue];
}

- (CGFloat)zd_max {
    return [[self valueForKeyPath:@"@max.floatValue"] floatValue];
}

- (CGFloat)zd_min {
    return [[self valueForKeyPath:@"@min.floatValue"] floatValue];
}

- (void)zd_forEach:(void(^)(id, NSUInteger))block {
    if (!block) return;
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx);
    }];
}

- (NSMutableArray *)zd_map:(id (^)(id, NSUInteger))block {
    NSMutableArray *mapedMutArr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = block ? block(obj, idx) : nil;
        if (value) {
            [mapedMutArr addObject:value];
        }
    }];
    
    return mapedMutArr;
}

- (NSMutableArray *)zd_filter:(BOOL (^)(id objc, NSUInteger idx))block {
    if (!block) return self.zd_mutableArray;
    
    NSMutableArray *filteredMutArr = @[].mutableCopy;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isPass = block(obj, idx);
        if (!isPass) {
            [filteredMutArr addObject:obj];
        }
    }];
    return filteredMutArr;
}

- (id)zd_reduce:(id(^)(id previousResult, id currentObject, NSUInteger idx))block {
    if (!block) return self;
    
    __block id result = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        result = block(result, obj, idx);
    }];
    return result;
}

- (NSMutableArray *)zd_flatten {
    NSMutableArray *flattenedMutArray = @[].mutableCopy;
    for (id value in self) {
        if ([value isKindOfClass:[NSArray class]]) {
            [flattenedMutArray addObjectsFromArray:[(NSArray *)value zd_flatten]];
        }
        else {
            [flattenedMutArray addObject:value];
        }
    }
    return flattenedMutArray;
}

- (NSMutableArray *)zd_zipWith:(NSArray *)rightArray usingBlock:(id(^)(id left, id right))block {
    NSUInteger minCount = MIN(self.count, rightArray.count);
    
    NSMutableArray *zipedMutableArray = [NSMutableArray arrayWithCapacity:minCount];
    for (NSUInteger i = 0; i < minCount; i++) {
        id value = block ? block(self[i], rightArray[i]) : nil;
        if (value) {
            [zipedMutableArray addObject:value];
        }
    }
    
    return zipedMutableArray;
}

- (NSMutableArray *)zd_mutableArray {
    if ([self isKindOfClass:[NSMutableArray class]]) {
        return (NSMutableArray *)self;
    }
    else {
        return [NSMutableArray arrayWithArray:self];
    }
}

@end

