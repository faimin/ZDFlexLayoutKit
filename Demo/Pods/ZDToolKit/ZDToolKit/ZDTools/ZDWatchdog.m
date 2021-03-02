//
//  ZDWatchdog.m
//  Pods
//
//  Created by Zero on 2016/12/8.
//
//

#import "ZDWatchdog.h"
#include <execinfo.h>

static const NSTimeInterval kDefaultInterval = 50.0; // 单位：毫秒

@interface ZDWatchdog () {
    CFRunLoopObserverRef _observer;
    @public
    dispatch_semaphore_t _semaphore;
    CFRunLoopActivity _activity;
}
@property (nonatomic, strong) dispatch_source_t timer;
@end


@implementation ZDWatchdog

#pragma mark - Lify Cycle

+ (instancetype)shareInstance {
    static ZDWatchdog *watchdog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!watchdog) {
            watchdog = [[self alloc] init];
        }
    });
    return watchdog;
}

#pragma mark - RunLoop

static void RunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    ZDWatchdog *watchdog = (__bridge ZDWatchdog *)(info);
    watchdog->_activity = activity;
    
    // 此针对于通用的第一种方案
    if (watchdog->_semaphore) {
        dispatch_semaphore_signal(watchdog->_semaphore);
    }
}

- (void)setupRunLoopObserver {
    if (_observer) return;
    
    // 创建添加观察者
    CFRunLoopObserverContext context;//{0, (__bridge void*)self, NULL, NULL, NULL};
    context.version         = 0;
    context.info            = (__bridge void *)self;
    context.retain          = &CFRetain;
    context.release         = &CFRelease;
    context.copyDescription = NULL;
    _observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                        kCFRunLoopAllActivities,
                                        true,
                                        0,
                                        RunLoopObserverCallBack,
                                        &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
}

#pragma mark - Public Method

- (void)start {
    [self setupRunLoopObserver];
    [self commonMethod];
    [self timerMethod];
}

- (void)commonMethod {
    _semaphore = dispatch_semaphore_create(0);

    // 在子线程监控
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger timeoutCount = 0; // 一次循环过程中的卡顿次数
        while (true) {
            //超时后返回非0值,未超时返回0;默认等待50毫秒 = 50/1000 秒
            long semaphoreResult = dispatch_semaphore_wait(self->_semaphore, dispatch_time(DISPATCH_TIME_NOW, (self.timeInterval ?: kDefaultInterval) * NSEC_PER_MSEC));
            if (semaphoreResult != 0) { //超时
                //runloop观察者不存在时重置所有条件
                if (!self->_observer) {
                    timeoutCount = 0;
                    self->_semaphore = NULL;
                    self->_activity = 0;
                }

                if (self->_activity == kCFRunLoopBeforeSources || self->_activity == kCFRunLoopAfterWaiting) {
                    if (++timeoutCount < 5) {
                        continue;
                    } else {
                        [self printTrace];
                    }
                }
            }

            //不超时的时候把卡顿次数重置为0(超时时执行++操作,然后continue跳过此处)
            timeoutCount = 0;
        }
    });
}

// https://www.tuicool.com/articles/bUv6fq6
- (void)timerMethod {
    __block int8_t chokeCount = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("zd.com.queue.serial.watchdog", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0));
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, serialQueue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, kDefaultInterval * NSEC_PER_MSEC, 0);
    __weak __typeof__(self) weakTarget = self;
    dispatch_source_set_event_handler(self.timer, ^{
        __strong __typeof__(weakTarget) self = weakTarget;
        if (!self) {
            return;
        }
        
        if (self->_activity == kCFRunLoopBeforeWaiting ||
            self->_activity == kCFRunLoopBeforeSources) {
            static BOOL isNotTimeOut = YES;
            if (isNotTimeOut == NO) {
                ++chokeCount;
                if (chokeCount > 40) {
                    NSLog(@"貌似卡死了❌❌❌");
                    dispatch_suspend(self.timer);
                    return;
                }
                else if (chokeCount > 5) {
                    NSLog(@"丢帧了❗️❗️❗️");
                    //[self printTrace];
                }
                return ;
            }
            
            // 在主线程发送信号,重置卡顿次数
            dispatch_async(dispatch_get_main_queue(), ^{
                isNotTimeOut = YES;
                dispatch_semaphore_signal(semaphore);
                chokeCount = 0;
            });
            
            // 超时时返回非0的数值
            long timeOut = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (self.timeInterval ?: kDefaultInterval) * NSEC_PER_MSEC));
            if (timeOut != 0) {
                isNotTimeOut = NO;
            };
        }
    });
    dispatch_resume(self.timer);
}

- (void)stop {
    if (!_observer) return;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    _observer = NULL;
}

#pragma mark - Private Method

- (void)printTrace {
    void *callstack[128];
    int count = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, count);
    NSMutableArray<NSString *> *backtraceArr = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        [backtraceArr addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    NSLog(@"卡顿堆栈===>\n%@\n----------------------------", backtraceArr);
}

@end

