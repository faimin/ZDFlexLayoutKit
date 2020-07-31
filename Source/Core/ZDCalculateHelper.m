//
//  ZDCalculateHelper.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/21.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDCalculateHelper.h"
#import <os/lock.h>

static NSMutableArray<dispatch_block_t> *_asyncTaskQueue = nil;
static CFRunLoopSourceRef _runloopSource = NULL;

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
        calculateQueue = dispatch_queue_create("queue.calculate.flexlayout.zd", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, 0));
    });
    return calculateQueue;
}

static void zd_addAsyncTaskBlockWithCompleteCallback(dispatch_block_t task, dispatch_block_t complete) {
    if (task == nil) return;
    
    _asyncTaskQueue = [[NSMutableArray alloc] init];
    
    dispatch_async(zd_calculate_queue(), ^{
        task();
        
        if (complete == nil) {
            return;
        }
        
        zd_lock(^{
            [_asyncTaskQueue addObject:complete];
            CFRunLoopSourceSignal(_runloopSource);
            CFRunLoopWakeUp(CFRunLoopGetMain());
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
}

static void zd_sourceContextCallBackLog(void *info) {
    NSLog(@"function name : (%s) ==> will calculate flex layout", __PRETTY_FUNCTION__);
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
    CFRunLoopRef runloop = CFRunLoopGetMain();
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit, true, INT_MAX, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        zd_executeAsyncTasks();
    });
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    
    CFRunLoopSourceContext *sourceContext = calloc(1, sizeof(CFRunLoopSourceContext));
    sourceContext->perform = zd_sourceContextCallBackLog;
    _runloopSource = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, sourceContext);
    CFRunLoopAddSource(runloop, _runloopSource, kCFRunLoopCommonModes);
}

+ (void)asyncCalculateTask:(dispatch_block_t)calculateTask onComplete:(dispatch_block_t)onComplete {
    NSCAssert(calculateTask, @"params can't be nil");
    if (!calculateTask) {
        return;
    }
    zd_addAsyncTaskBlockWithCompleteCallback(calculateTask, onComplete);
}

@end
