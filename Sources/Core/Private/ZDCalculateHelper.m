//
//  ZDCalculateHelper.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/21.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDCalculateHelper.h"
#import <os/lock.h>

static NSMutableOrderedSet<dispatch_block_t> *_asyncTaskQueue = nil;
static NSMutableOrderedSet<dispatch_block_t> *_asyncMainThreadQueue = nil;
static dispatch_group_t _taskGroup = NULL;
static CFRunLoopSourceRef _runloopSource = NULL;

// 此函数不是线程安全的，但是计算函数一般都是在主线程调用的，所以就暂不加锁了
static void zd_init(void) {
    if (!_asyncTaskQueue) {
        _asyncTaskQueue = [[NSMutableOrderedSet alloc] init];
    }
    
    if (!_asyncMainThreadQueue) {
        _asyncMainThreadQueue = [NSMutableOrderedSet orderedSet];
    }
    
    if (!_taskGroup) {
        _taskGroup = dispatch_group_create();
    }
}

static void zd_lock(dispatch_block_t callback) {
    if (!callback) {
        return;
    }
    
    if (@available(iOS 10.0, *)) {
        static os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
        os_unfair_lock_lock(&lock);
        callback();
        os_unfair_lock_unlock(&lock);
    }
    else {
        static dispatch_semaphore_t lock = NULL;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            lock = dispatch_semaphore_create(1);
        });
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        callback();
        dispatch_semaphore_signal(lock);
    }
}

static dispatch_queue_t zd_calculate_queue() {
    static dispatch_queue_t calculateQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calculateQueue = dispatch_queue_create("queue.calculate.flexlayout.zd", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INTERACTIVE, 0));
    });
    return calculateQueue;
}

__attribute__((__overloadable__)) static void zd_addAsyncTaskBlockWithCompleteCallback(dispatch_block_t task, dispatch_block_t complete) {
    if (task == nil) return;
    
    zd_init();
    
    dispatch_group_enter(_taskGroup);
    dispatch_async(zd_calculate_queue(), ^{
        task();
                
        zd_lock(^{
            [_asyncTaskQueue addObject:^{
                dispatch_group_leave(_taskGroup);
                if (complete) {
                    complete();
                }
            }];
            CFRunLoopSourceSignal(_runloopSource);
            //CFRunLoopWakeUp(CFRunLoopGetMain());
        });
    });
    dispatch_group_notify(_taskGroup, dispatch_get_main_queue(), ^{
        NSLog(@"计算完成");
    });
}

__attribute__((__overloadable__)) static void zd_addAsyncTaskBlockWithCompleteCallback(NSArray<dispatch_block_t> *tasks, dispatch_block_t allComplete) {
    if (tasks == nil || tasks.count == 0) return;
    
    zd_init();
    
    dispatch_group_enter(_taskGroup);
    dispatch_async(zd_calculate_queue(), ^{
        for (dispatch_block_t task in tasks) {
            task();
        }
        dispatch_group_leave(_taskGroup);
    });
    dispatch_group_notify(_taskGroup, dispatch_get_main_queue(), ^{
        if (allComplete) {
            allComplete();
        }
        printf("任务组计算完成");
    });
}

static void zd_executeAsyncTasks(void) {
    zd_lock(^{
        // onComplete block
        for (dispatch_block_t task in _asyncTaskQueue) {
            task();
        }
        [_asyncTaskQueue removeAllObjects];
    });
}

static void zd_executeMainThreadAsyncTasks(void) {
    if (!_asyncMainThreadQueue) {
        return;
    }
    NSOrderedSet *tasks = _asyncMainThreadQueue.copy;
    for (dispatch_block_t task in tasks) {
        task();
    }
}

static void zd_sourceContextCallBackLog(void *info) {
    NSLog(@"function name : (%s) ==> will calculate flex layout", __PRETTY_FUNCTION__);
}

static void zd_initRunloop() {
    CFRunLoopRef runloop = CFRunLoopGetMain();
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit, true, INT_MAX, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        zd_executeAsyncTasks();
        zd_executeMainThreadAsyncTasks();
    });
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    
    CFRunLoopSourceContext *sourceContext = calloc(1, sizeof(CFRunLoopSourceContext));
    sourceContext->perform = zd_sourceContextCallBackLog;
    _runloopSource = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, sourceContext);
    free(sourceContext);
    CFRunLoopAddSource(runloop, _runloopSource, kCFRunLoopCommonModes);
    CFRelease(_runloopSource);
}

static void zd_autoLayoutWhenIdle(dispatch_block_t layoutTask) {
    if (!layoutTask) {
        return;
    }
    
    zd_init();
    [_asyncMainThreadQueue addObject:layoutTask];
}

#pragma mark -

@implementation ZDCalculateHelper

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupRunloop];
    });
}

+ (void)setupRunloop {
    zd_initRunloop();
}

#pragma mark - Thread

+ (void)asyncCalculateTask:(dispatch_block_t)calculateTask onComplete:(dispatch_block_t)onComplete {
    NSCAssert(calculateTask, @"params can't be nil");
    if (!calculateTask) {
        return;
    }
    zd_addAsyncTaskBlockWithCompleteCallback(calculateTask, onComplete);
}

+ (void)asyncCalculateMultiTasks:(NSArray<dispatch_block_t> *)calculateTasks onComplete:(dispatch_block_t)onComplete {
    NSCAssert(calculateTasks, @"params can't be nil");
    if (!calculateTasks || calculateTasks.count == 0) {
        return;
    }
    zd_addAsyncTaskBlockWithCompleteCallback(calculateTasks, onComplete);
}

#pragma mark - Runloop Idle

+ (void)asyncLayoutTask:(dispatch_block_t)layoutTask {
    if (!layoutTask) {
        return;
    }
    zd_autoLayoutWhenIdle(layoutTask);
}

+ (void)removeAsyncLayoutTask:(dispatch_block_t)layoutTask {
    if (!layoutTask) {
        return;
    }
    [_asyncMainThreadQueue removeObject:layoutTask];
}

@end
