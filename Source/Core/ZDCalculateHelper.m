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

static NSMutableArray<dispatch_block_t> *_taskQueue = nil;
static CFRunLoopSourceRef _runloopSource = NULL;

/*
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

static dispatch_queue_t zd_display_queue() {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("queue.display.flexlayout.zd", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0));
    });
    return queue;
}
*/

static void zd_addTask(dispatch_block_t task) {
    if (task == nil) return;
    
    if (!_taskQueue) {
        _taskQueue = [[NSMutableArray<dispatch_block_t> alloc] init];
    }
    [_taskQueue addObject:task];
    //CFRunLoopWakeUp(CFRunLoopGetMain());
}

static void zd_executeTasks() {
    for (dispatch_block_t taskBlock in _taskQueue) {
        taskBlock();
    }
    [_taskQueue removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZDCalculateFinishedNotification object:nil userInfo:nil];
}

#pragma mark -

@implementation ZDCalculateHelper

+ (void)load {
    [self setupRunloop];
}

+ (void)setupRunloop {
    CFRunLoopRef runloop = CFRunLoopGetMain();
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        zd_executeTasks();
    });
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
    
    CFRunLoopSourceContext sourceContext = {};
    _runloopSource = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, &sourceContext);
    CFRunLoopAddSource(runloop, _runloopSource, kCFRunLoopDefaultMode);
}

+ (void)addCalculateTask:(dispatch_block_t)calculateTask {
    NSCAssert(calculateTask, @"params con't be nil");

    zd_addTask(calculateTask);
}

@end
