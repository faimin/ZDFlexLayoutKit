//
//  ZDLinkedMap.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/8/14.
//
//  reference: https://github.com/ibireme/YYKit

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDLinkedMap<__covariant KeyType, __covariant ObjectType> : NSObject <NSFastEnumeration>

//- (void)insertNodeAtHead:(ZDLinkedMapNode *)node;
//- (void)addNodeToTail:(ZDLinkedMapNode *)node;
//- (void)bringNodeToHead:(ZDLinkedMapNode *)node;
//- (void)removeNode:(ZDLinkedMapNode *)node;
//- (ZDLinkedMapNode *)removeTailNode;
//- (void)removeAllNode;

- (BOOL)containsObjectForKey:(KeyType)key;
- (ObjectType _Nullable)objectForKey:(KeyType)key;
- (void)setObject:(ObjectType _Nullable)object forKey:(KeyType)key;
- (void)removeObjectForKey:(KeyType)key;
- (void)removeAllObjects;
- (ObjectType _Nullable)objectAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
