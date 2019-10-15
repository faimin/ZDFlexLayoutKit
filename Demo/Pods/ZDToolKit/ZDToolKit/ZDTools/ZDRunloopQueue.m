//
//  ZDRunloopQueue.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2017/12/16.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//
//  https://github.com/Cascable/runloop-queue/blob/master/RunloopQueue/RunloopQueue.swift

#import "ZDRunloopQueue.h"

@interface ZDRunloopQueueThread : NSThread
- (void)startWhenReady:(void(^)(CFRunLoopRef))callback;
- (void)awake;
@end

//------------------------------------------------------

@interface ZDRunloopQueue ()
@property (nonatomic, strong) ZDRunloopQueueThread *thread;
@property (nonatomic, assign) CFRunLoopRef runloop;
@end

@implementation ZDRunloopQueue

- (void)dealloc {
    CFRunLoopRef runloop = self.runloop;
    [self sync:^{
        CFRunLoopStop(runloop);
    }];
}

/// Init a new queue with the given name.
///
/// - Parameter name: The name of the queue.
- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _thread = [[ZDRunloopQueueThread alloc] init];
        _thread.name = name;
        [self startRunloop];
    }
    return self;
}

/// Returns `true` if the queue is running, otherwise `false`. Once stopped, a queue cannot be restarted.
- (BOOL)running {
    return YES;
}

/// Execute a block of code in an asynchronous manner. Will return immediately.
///
/// - Parameter block: The block of code to execute.
- (void)async:(void(^)(void))block {
    CFRunLoopPerformBlock(self.runloop, kCFRunLoopDefaultMode, block);
    [self.thread awake];
}

/// Execute a block of code in a synchronous manner. Will return when the code has executed.
///
/// It's important to be careful with `sync()` to avoid deadlocks. In particular, calling `sync()` from inside
/// a block previously passed to `sync()` will deadlock if the second call is made from a different thread.
///
/// - Parameter block: The block of code to execute.
- (void)sync:(void(^)(void))block {
    if ([self isRunningOnQueue]) {
        if (block) block();
        return;
    }
    
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    CFRunLoopPerformBlock(self.runloop, kCFRunLoopDefaultMode, ^{
        [conditionLock lock];
        if (block) block();
        [conditionLock unlockWithCondition:1];
    });
    
    [self.thread awake];
    [conditionLock lockWhenCondition:1];
    [conditionLock unlock];
}

/// Query if the caller is running on this queue.
///
/// - Returns: `true` if the caller is running on this queue, otherwise `false`.
- (BOOL)isRunningOnQueue {
    return CFEqual(CFRunLoopGetCurrent(), self.runloop);
}

//MARK: - Code That Runs On The Background Thread
- (void)startRunloop {
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    __weak typeof(self) weakSelf = self;
    // This is on the background thread.
    [self.thread startWhenReady:^(CFRunLoopRef runloop) {
        [conditionLock lock];
        if (weakSelf) {
            weakSelf.runloop = runloop;
        }
        [conditionLock unlockWithCondition:1];
    }];
    [conditionLock lockWhenCondition:1];
    [conditionLock unlock];
}

@end

//------------------------------------------------------------------

static void _sourceContextPerformCallBack(void *info) {
    NSLog(@"execute...");
}

@interface ZDRunloopQueueThread ()
@property (nonatomic, assign) CFRunLoopSourceRef runloopSource;
@property (nonatomic, assign) CFRunLoopRef currentRunloop;
@property (nonatomic, copy  ) void(^whenReadyCallBack)(CFRunLoopRef);
@end

@implementation ZDRunloopQueueThread

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    CFRunLoopSourceContext sourceContext = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &_sourceContextPerformCallBack};
    self.runloopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
}

- (void)startWhenReady:(void(^)(CFRunLoopRef))callback {
    self.whenReadyCallBack = callback;
    [self start];
}

- (void)awake {
    if (!self.currentRunloop) return;
    
    if (CFRunLoopIsWaiting(self.currentRunloop)) {
        CFRunLoopSourceSignal(self.runloopSource);
        CFRunLoopWakeUp(self.currentRunloop);
    }
}

#pragma mark - Override

- (void)main {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    self.currentRunloop = runloop;
    
    CFRunLoopAddSource(runloop, self.runloopSource, kCFRunLoopCommonModes);
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, false, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (self.whenReadyCallBack) self.whenReadyCallBack(runloop);
    });
    
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRunLoopRun();
    CFRunLoopRemoveObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRunLoopRemoveSource(runloop, self.runloopSource, kCFRunLoopCommonModes);
    self.currentRunloop = nil;
}

@end

