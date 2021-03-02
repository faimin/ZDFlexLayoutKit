//
//  ZDOrderedDictionary.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDOrderedDictionary<__covariant KeyType, __covariant ObjectType> : NSObject <NSFastEnumeration>

@property (nonatomic, copy, readonly) NSArray<KeyType> *allKeys;
@property (nonatomic, copy, readonly) NSArray<ObjectType> *allValues;

- (void)setObject:(ObjectType _Nullable)anObject forKey:(KeyType<NSCopying>)aKey;
- (void)removeObjectForKey:(KeyType<NSCopying>)aKey;
- (void)insertObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey atIndex:(NSInteger)index;
- (ObjectType _Nullable)objectAtIndex:(NSInteger)index;
- (ObjectType _Nullable)objectForKey:(KeyType<NSCopying>)aKey;
- (void)removeAllObjects;

/// 实现下标语法糖
- (ObjectType _Nullable)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(ObjectType _Nullable)obj atIndexedSubscript:(NSUInteger)idx NS_UNAVAILABLE;
- (ObjectType _Nullable)objectForKeyedSubscript:(KeyType)key;
- (void)setObject:(ObjectType _Nullable)obj forKeyedSubscript:(KeyType)key;

@end

NS_ASSUME_NONNULL_END
