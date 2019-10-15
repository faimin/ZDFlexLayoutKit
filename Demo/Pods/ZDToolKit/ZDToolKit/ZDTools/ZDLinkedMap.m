//
//  ZDLinkedMap.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/8/14.
//

#import "ZDLinkedMap.h"
#import <pthread/pthread.h>

@interface ZDLinkedMapNode<__covariant KeyType, __covariant ObjectType> : NSObject {
    @package
    __unsafe_unretained ZDLinkedMapNode *_previous;
    __unsafe_unretained ZDLinkedMapNode *_next;
    KeyType _key;
    ObjectType _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end

//------------------------------------------

@interface ZDLinkedMap () {
    @package
    pthread_mutex_t _lock;
    CFMutableDictionaryRef _dict;
    ZDLinkedMapNode *_head;
    ZDLinkedMapNode *_tail;
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
    @private
    dispatch_queue_t _releaseQueue;
}
@end

@implementation ZDLinkedMap

- (void)dealloc {
    CFRelease(_dict);
    pthread_mutex_destroy(&_lock);
    _releaseQueue = NULL;
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _releaseQueue = dispatch_queue_create("com.zero.linkedmap.release.queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0));
        _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

#pragma mark - Private

- (void)insertNodeAtHead:(ZDLinkedMapNode *)node {
    if (!node) return;
    
    CFDictionarySetValue(_dict, (__bridge const void *)(node->_key), (__bridge const void *)(node->_value));
    _totalCost += node->_cost;
    ++_totalCount;
    if (_head) {
        node->_next = _head;
        _head->_previous = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)addNodeToTail:(ZDLinkedMapNode *)node {
    if (!node) return;
    
    CFDictionarySetValue(_dict, (__bridge const void *)(node->_key), (__bridge const void *)(node->_value));
    _totalCost += node->_cost;
    ++_totalCount;
    if (_tail) {
        node->_previous = _tail;
        _tail->_next = node;
        _tail = node;
    } else {
        _tail = _head = node;
    }
}

- (void)bringNodeToHead:(ZDLinkedMapNode *)node {
    if (!node) return;
    
    if (_head == node) return;
    
    if (_tail == node) {
        _tail = node->_previous;
        _tail->_next = nil;
    } else {
        node->_next->_previous = node->_previous;
        node->_previous->_next = node->_next;
    }
    node->_next = _head;
    node->_previous = nil;
    _head->_previous = node;
    _head = node;
}

- (void)removeNode:(ZDLinkedMapNode *)node {
    CFDictionaryRemoveValue(_dict, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    --_totalCount;
    if (node->_next) node->_next->_previous = node->_previous;
    if (node->_previous) node->_previous->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_previous;
}

- (ZDLinkedMapNode *)removeTailNode {
    if (!_tail) return nil;
    
    ZDLinkedMapNode *tail = _tail;
    CFDictionaryRemoveValue(_dict, (__bridge const void *)(_tail->_key));
    _totalCost -= _tail->_cost;
    --_totalCount;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_previous;
        _tail->_next = nil;
    }
    return tail;
}

- (void)removeAllNode {
    _totalCost = 0;
    _totalCount = 0;
    _head = _tail = nil;
    
    if (CFDictionaryGetCount(_dict) == 0) return;
        
    CFMutableDictionaryRef holder = _dict;
    _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    if (_releaseAsynchronously) {
        dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : _releaseQueue;
        dispatch_async(queue, ^{
            CFRelease(holder); // hold and release in specified queue
        });
    } else if (_releaseOnMainThread && !pthread_main_np()) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CFRelease(holder); // hold and release in specified queue
        });
    } else {
        CFRelease(holder);
    }
}

- (ZDLinkedMapNode *)nodeAtIndex:(NSUInteger)index {
    if (index == 0) return _head;
    if (index == _totalCount-1) return _tail;
    if (index >= _totalCount) return nil;
    
    NSUInteger middle = _totalCount / 2;
    ZDLinkedMapNode *node = nil;
    if (index <= middle) {
        NSUInteger i = 1;
        node = _head->_next;
        while (i != index) {
            ++i;
            if (!node) continue;
            node = node->_next;
        }
    } else {
        node = _tail;
        for (NSUInteger i = _totalCount-2; i != index; --i) {
            if (!node) continue;
            node = node->_previous;
        }
    }
    
    return node;
}

#pragma mark - Public

- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_dict, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    ZDLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)(key));
    if (node) {
        node->_time = CACurrentMediaTime();
        [self bringNodeToHead:node];
    }
    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    pthread_mutex_lock(&_lock);
    ZDLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        self->_totalCost -= node->_cost;
        self->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [self bringNodeToHead:node];
    } else {
        node = [[ZDLinkedMapNode alloc] init];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [self insertNodeAtHead:node];
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(id)key {
    if (!key) return;
    
    pthread_mutex_lock(&_lock);
    ZDLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)(key));
    if (node) {
        [self removeNode:node];
        if (self->_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : _releaseQueue;
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (self->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    [self removeAllNode];
    pthread_mutex_unlock(&_lock);
}

- (id)objectAtIndex:(NSUInteger)index {
    pthread_mutex_lock(&_lock);
    ZDLinkedMapNode *node = [self nodeAtIndex:index];
    id value = node->_value;
    pthread_mutex_unlock(&_lock);
    return value;
}

#pragma mark - NSFastEnumeration

//https://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    if (state->state == 0) {
        state->mutationsPtr = state->mutationsPtr;
        state->extra[0] = (unsigned long)_head; // 1
        state->state = 1;
    }
    
    ZDLinkedMapNode *currentNode = (__bridge ZDLinkedMapNode *)(void *)(state->extra[0]);
    
    state->itemsPtr = stackbuf; // 2
    
    NSUInteger count = 0;
    while (currentNode && count < len) { // 3
        stackbuf[count++] = currentNode->_value;
        currentNode = currentNode->_next;
    }
    
    if (currentNode) {
        state->extra[0] = (unsigned long)currentNode->_next; // 4
    }
    
    return count;
}

@end

//--------------------------------------------------------------------------------------

@implementation ZDLinkedMapNode
@end

