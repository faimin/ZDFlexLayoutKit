//
//  ZDMutableDictionary.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/13.
//
//  https://github.com/ibireme/YYKit/blob/master/YYKit/Utility/YYThreadSafeDictionary.m
//  https://github.com/githubliuming/QYFoundationHelper/blob/5dbe7a503269ce503f6a6e6bea846e49f93ddbee/QYFoundationHelper/QYContainer/QYMutableDictionary.m

#import "ZDMutableDictionary.h"

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_zdInnerMutDict) return nil; \
_zdInnerQueue = dispatch_queue_create("com.queue.concurrent.dictionary", DISPATCH_QUEUE_CONCURRENT); \
_lock = dispatch_semaphore_create(1); \
return self;

@implementation ZDMutableDictionary {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _zdInnerQueue;
    NSMutableDictionary *_zdInnerMutDict;
}

- (void)dealloc {
    _zdInnerMutDict = nil;
    _zdInnerQueue = nil;
    _lock = nil;
}

#pragma mark - Initialization

- (instancetype)init {
    INIT(_zdInnerMutDict = [[NSMutableDictionary alloc] init];)
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
    INIT(_zdInnerMutDict = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];)
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_zdInnerMutDict = [NSMutableDictionary dictionaryWithCapacity:numItems];)
}

- (NSDictionary *)initWithContentsOfFile:(NSString *)path {
    INIT(_zdInnerMutDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];)
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    INIT(_zdInnerMutDict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];)
}

- (instancetype)initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    if (!objects || !keys) {
        [NSException raise:NSInvalidArgumentException format:@"objects and keys cannot be nil"];
        return nil;
    }
    
    INIT(_zdInnerMutDict = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    INIT(_zdInnerMutDict = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    INIT(_zdInnerMutDict = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag]);
}

#pragma mark -

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(_zdInnerQueue, ^{
        count = self->_zdInnerMutDict.count;
    });
    return count;
}

- (id)objectForKey:(id)aKey {
    if (!aKey) return nil;
    
    __block id obj;
    dispatch_sync(_zdInnerQueue, ^{
        obj = self->_zdInnerMutDict[aKey];
    });
    return obj;
}

- (NSEnumerator *)keyEnumerator {
    __block NSEnumerator *enu;
    dispatch_sync(_zdInnerQueue, ^{
        enu = [self->_zdInnerMutDict keyEnumerator];
    });
    return enu;
}

- (NSArray *)allKeys {
    __block NSArray *allKeys;
    dispatch_sync(_zdInnerQueue, ^{
        allKeys = [self->_zdInnerMutDict allKeys];
    });
    return allKeys;
}

- (NSArray *)allKeysForObject:(id)anObject {
    __block NSArray *allKeys;
    dispatch_sync(_zdInnerQueue, ^{
        allKeys = [self->_zdInnerMutDict allKeysForObject:anObject];
    });
    return allKeys;
}

- (NSArray *)allValues {
    __block NSArray *allValues;
    dispatch_sync(_zdInnerQueue, ^{
        allValues = [self->_zdInnerMutDict allValues];
    });
    return allValues;
}

#pragma mark -

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) return;
    
    aKey = [aKey copyWithZone:NULL];
    dispatch_barrier_async(_zdInnerQueue, ^{
        self->_zdInnerMutDict[aKey] = anObject;
    });
}

- (void)removeObjectForKey:(id)aKey {
    if (!aKey) return;
    
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutDict removeObjectForKey:aKey];
    });
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutDict addEntriesFromDictionary:otherDictionary];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutDict removeAllObjects];
    });
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutDict removeObjectsForKeys:keyArray];
    });
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutDict setDictionary:otherDictionary];
    });
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying> )key {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutDict setObject:obj forKeyedSubscript:key];
    });
}

@end
