//
//  NSArray+ZDExtend.m
//  ZDUtility
//
//  Created by Zero on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSArray+ZDUtility.h"

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

- (__kindof NSArray *)zd_shuffle {
    if (self.count > 0) {
        NSMutableArray *mutArr = [self isKindOfClass:[NSMutableArray class]] ? self : [self mutableCopy];
        for (NSUInteger i = self.count; i > 1; i--) {
            [mutArr exchangeObjectAtIndex:(i - 1)
                      withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
        return mutArr;
    }
    return self;
}

- (__kindof NSArray *)zd_moveObjcToFront:(id)objc {
    if ([self containsObject:objc]) {
        NSMutableArray *mutArr = [self isKindOfClass:[NSMutableArray class]] ? self : [self mutableCopy];
        [mutArr removeObject:objc];
        [mutArr insertObject:objc atIndex:0];
        return mutArr;
    }
    return self;
}

- (NSArray *)zd_deduplication {
#if 1
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueCoding/CollectionOperators.html
    return [self valueForKeyPath:@"@distinctUnionOfObjects.self"];
#else
    return [NSSet setWithArray:self].allObjects;
#endif
}

- (NSArray *)zd_collectSameElementWithArray:(__kindof NSArray *)otherArray {
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

- (NSMutableArray *)zd_map:(id (^)(id objc))block {
    NSMutableArray *mapedMutArr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = block ? block(obj) : nil;
        if (value) {
            [mapedMutArr addObject:value];
        }
    }];
    
    return mapedMutArr;
}

- (NSMutableArray *)zd_filter:(BOOL (^)(id objc))block {
    if (!block) return self.zd_mutableArray;
    
    NSMutableArray *filteredMutArr = @[].mutableCopy;
    for (id value in self) {
        if (block(value)) {
            [filteredMutArr addObject:value];
        }
    }
    return filteredMutArr;
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

