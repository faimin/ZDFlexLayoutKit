//
//  ZDCalculateHelper.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/21.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDCalculateHelper.h"
#import <os/lock.h>

NSString *const ZDCalculateFinishedNotification = @"ZDCalculateFinishedNotification";

static NSMutableArray<NSMutableArray<dispatch_block_t> *> *_syncTaskQueue = nil;
static NSMutableArray<dispatch_block_t> *_asyncTaskQueue = nil;
static CFRunLoopSourceRef _runloopSource = NULL;

static void zd_lock(dispatch_block_t callback) {
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
        calculateQueue = dispatch_queue_create("queue.calculate.flexlayout.zd", DISPATCH_QUEUE_SERIAL);
    });
    return calculateQueue;
}

//static dispatch_queue_t zd_display_queue() {
//    static dispatch_queue_t queue = NULL;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        queue = dispatch_queue_create("queue.display.flexlayout.zd", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0));
//    });
//    return queue;
//}

static void zd_addSyncTaskBlockWithCompleteCallback(dispatch_block_t task, dispatch_block_t complete) {
    if (task == nil) return;

    _syncTaskQueue = [[NSMutableArray alloc] init];

    zd_lock(^{
        NSMutableArray *taskAndComplteArray = @[].mutableCopy;
        [taskAndComplteArray addObject:task];
        if (complete) {
            [taskAndComplteArray addObject:complete];
        }
        [_syncTaskQueue addObject:taskAndComplteArray];
        CFRunLoopSourceSignal(_runloopSource);
        CFRunLoopWakeUp(CFRunLoopGetMain());
    });
}

static void zd_executeSyncTasks() {
    zd_lock(^{
        for (NSMutableArray *tasks in _syncTaskQueue) {
            // task block
            dispatch_block_t task = tasks.firstObject;
            task();
            if (tasks.count >= 2) {
                // onComplete block
                dispatch_block_t onComplete = tasks[2];
                onComplete();
            }
        }
        [_syncTaskQueue removeAllObjects];
    });

    //[[NSNotificationCenter defaultCenter] postNotificationName:ZDCalculateFinishedNotification object:nil userInfo:nil];
}

static void zd_addAsyncTaskBlockWithCompleteCallback(dispatch_block_t task, dispatch_block_t complete) {
    if (task == nil) return;
    
    _asyncTaskQueue = [[NSMutableArray alloc] init];
    
    dispatch_async(zd_calculate_queue(), ^{
        task();
        zd_lock(^{
            [_asyncTaskQueue addObject:complete];
        });
    });
}

static void zd_executeAsyncTasks() {
    zd_lock(^{
        // onComplete block
        for (dispatch_block_t task in _asyncTaskQueue) {
            task();
        }
        [_asyncTaskQueue removeAllObjects];
    });
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:ZDCalculateFinishedNotification object:nil userInfo:nil];
}

static void zd_sourceContextCallBackLog(void *info) {
  NSLog(@"applay FlexBox layout");
}

#pragma mark -

@implementation ZDCalculateHelper

+ (void)load {
    [self setupRunloop];
}

+ (void)setupRunloop {
    CFRunLoopRef runloop = CFRunLoopGetMain();
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit, true, INT_MAX, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        zd_executeSyncTasks();
        zd_executeAsyncTasks();
    });
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    
    CFRunLoopSourceContext *sourceContext = calloc(1, sizeof(CFRunLoopSourceContext));
    sourceContext->perform = zd_sourceContextCallBackLog;
    _runloopSource = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, sourceContext);
    CFRunLoopAddSource(runloop, _runloopSource, kCFRunLoopCommonModes);
}

+ (void)async:(BOOL)isAsync addCalculateTask:(dispatch_block_t)calculateTask onComplete:(dispatch_block_t)onComplete {
    NSCAssert(calculateTask, @"params can't be nil");
    if (isAsync) {
        zd_addAsyncTaskBlockWithCompleteCallback(calculateTask, onComplete);
    }
    else {
        zd_addSyncTaskBlockWithCompleteCallback(calculateTask, onComplete);
    }
}

@end
