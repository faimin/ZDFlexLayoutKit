//
//  ZDMutableArray.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/1/31.
//

#import "ZDMutableArray.h"

@interface ZDMutableArray ()
@property (nonatomic, strong) NSMutableArray *zdInnerMutArray;
@end

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_zdInnerMutArray) return nil; \
_zdInnerQueue = dispatch_queue_create("com.queue.concurrent.array", DISPATCH_QUEUE_CONCURRENT); \
_lock = dispatch_semaphore_create(1); \
return self;

@implementation ZDMutableArray {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _zdInnerQueue;
}

- (void)dealloc {
    _zdInnerMutArray = nil;
    _zdInnerQueue = nil;
    _lock = nil;
}

#pragma mark - Initialization

- (instancetype)init {
    INIT(_zdInnerMutArray = [[NSMutableArray alloc] init];)
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_zdInnerMutArray = [[NSMutableArray alloc] initWithCapacity:numItems];)
}

- (NSArray *)initWithContentsOfFile:(NSString *)path {
    INIT(_zdInnerMutArray = [[NSMutableArray alloc] initWithContentsOfFile:path];)
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    INIT(_zdInnerMutArray = [[NSMutableArray alloc] initWithCoder:aDecoder];)
}

- (instancetype)initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    INIT(_zdInnerMutArray = [[NSMutableArray alloc] initWithObjects:objects count:cnt];)
}

#pragma mark -

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(_zdInnerQueue, ^{
        count = self->_zdInnerMutArray.count;
    });
    return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    if (self.zdInnerMutArray.count <= index) return nil;
    
    __block id obj;
    dispatch_sync(_zdInnerQueue, ^{
        obj = self->_zdInnerMutArray[index];
    });
    return obj;
}

- (NSEnumerator *)keyEnumerator {
    __block NSEnumerator *enu;
    dispatch_sync(_zdInnerQueue, ^{
        enu = [self->_zdInnerMutArray objectEnumerator];
    });
    return enu;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutArray insertObject:anObject atIndex:index];
    });
}

- (void)addObject:(id)anObject {
    if (!anObject) return;
    
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutArray addObject:anObject];
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (self.zdInnerMutArray.count <= index) return;
    
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutArray removeObjectAtIndex:index];
    });
}

- (void)removeLastObject {
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutArray removeLastObject];
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject; {
    if (self.zdInnerMutArray.count <= index) return;
    
    dispatch_barrier_async(_zdInnerQueue, ^{
        [self->_zdInnerMutArray replaceObjectAtIndex:index withObject:anObject];
    });
}

- (NSUInteger)indexOfObject:(id)anObject {
    __block NSUInteger index = NSNotFound;
    if (!anObject) return index;
    
    dispatch_sync(_zdInnerQueue, ^{
        index = [self->_zdInnerMutArray indexOfObject:anObject];
    });
    return index;
}

@end
