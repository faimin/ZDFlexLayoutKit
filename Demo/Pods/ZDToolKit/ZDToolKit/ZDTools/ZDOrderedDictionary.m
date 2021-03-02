//
//  ZDOrderedDictionary.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/3/20.
//

#import "ZDOrderedDictionary.h"
#import <pthread/pthread.h>

@interface ZDOrderedDictionary ()
@property (nonatomic, strong) NSMutableOrderedSet *innerKeys;
@property (nonatomic, strong) NSMutableDictionary *innerDict;
@property (nonatomic) pthread_mutex_t lock;
@end

@implementation ZDOrderedDictionary

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _innerKeys = [NSMutableOrderedSet orderedSet];
        _innerDict = @{}.mutableCopy;
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self setObject:anObject forKeyedSubscript:aKey];
}

- (void)insertObject:(id)anObject forKey:(id<NSCopying>)aKey atIndex:(NSInteger)index {
    if (!aKey || !anObject) return;
    // 可以等于
    if (index < 0 || index > self.innerKeys.count) return;
    
    pthread_mutex_lock(&_lock);
    if (self.innerDict[aKey]) {
        [self.innerKeys removeObject:aKey];
    }
    [self.innerKeys insertObject:aKey atIndex:index];
    self.innerDict[aKey] = anObject;
    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(id<NSCopying>)aKey {
    [self setObject:nil forKeyedSubscript:aKey];
}

- (id)objectAtIndex:(NSInteger)index {
    if (index < 0) return nil;
    
    return [self objectAtIndexedSubscript:index];
}

- (id)objectForKey:(id<NSCopying>)aKey {
    return [self objectForKeyedSubscript:aKey];
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    [self.innerDict removeAllObjects];
    [self.innerKeys removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (NSArray *)allKeys {
    NSArray *keys = [NSArray arrayWithArray:self.innerKeys.array];
    return keys;
}

- (NSArray *)allValues {
    pthread_mutex_lock(&_lock);
    NSMutableArray *values = @[].mutableCopy;
    for (id<NSCopying> key in self.innerKeys) {
        id value = self.innerDict[key];
        [values addObject:value];
    }
    NSArray *result = values.copy;
    pthread_mutex_unlock(&_lock);
    
    return result;
}

#pragma mark - 语法糖

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx >= self.innerKeys.count) return nil;
    
    pthread_mutex_lock(&_lock);
    id key = [self.innerKeys objectAtIndex:idx];
    if (!key) {
        pthread_mutex_unlock(&_lock);
        return nil;
    }
    
    id value = self.innerDict[key];
    pthread_mutex_unlock(&_lock);
    return value;
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    NSCAssert(NO, @"不支持,因为key必须要存在");
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key {
    if (!key) return nil;
    
    pthread_mutex_lock(&_lock);
    id value = self.innerDict[key];
    pthread_mutex_unlock(&_lock);
    
    return value;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) return;
    
    pthread_mutex_lock(&_lock);
    if (obj) {
        [self.innerKeys addObject:key];
    }
    else if (!obj && self.innerDict[key]) {
        [self.innerKeys removeObject:key];
    }
    self.innerDict[key] = obj;
    pthread_mutex_unlock(&_lock);
}

#pragma mark - NSFastEnumeration

// https://developer.apple.com/library/archive/samplecode/FastEnumerationSample/Listings/EnumerableClass_mm.html#//apple_ref/doc/uid/DTS40009411-EnumerableClass_mm-DontLinkElementID_4
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    
    unsigned long countOfItemAlreadyEnumerated = state->state;
    if (countOfItemAlreadyEnumerated == 0) {
        // 这是一个无符号长整形的指针，它指向的数据表示了遍历过程中集合是否发生了变化，如果数据变化了，那么集合也发生了变化。
        // 通常来讲，我们是不允许在遍历过程中修改集合的，所以如果你不允许这个操作可以将 mutationsPtr 指向一个不会改变的变量。苹果要求这个指针是非 NULL 的，所以一定要设置一个有效的值。
        state->mutationsPtr = &state->extra[0];
    }
    
    NSUInteger keyCount = self.innerKeys.count;
    NSUInteger count = 0;
    if (countOfItemAlreadyEnumerated < keyCount) {
        while (countOfItemAlreadyEnumerated < keyCount && count < len) {
            buffer[count++] = self.innerKeys[countOfItemAlreadyEnumerated]; // buffer C数组中最多可以放len个对象
            ++countOfItemAlreadyEnumerated;
        }
        state->itemsPtr = buffer;
    }
    else {
        count = 0;
    }
    
    state->state = countOfItemAlreadyEnumerated;
    
    // 如果返回值非零，则表示遍历并没有结束，Objective-C 还会再次调用这个方法，
    // 并且复用上次的 NSFastEnumerationState 结构体参数
    return count;
}

@end
