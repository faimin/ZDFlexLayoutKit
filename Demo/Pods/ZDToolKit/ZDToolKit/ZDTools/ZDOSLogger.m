//
//  ZDOSLogger.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2020/8/7.
//

#import "ZDOSLogger.h"
#import <os/lock.h>

@interface ZDOSLogger ()
@property (nonatomic, copy) NSString *subsystem;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) os_log_t osLog;
@end

@implementation ZDOSLogger

+ (instancetype)shareInstance {
    static ZDOSLogger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithSubsystem:[NSBundle bundleForClass:self].bundleIdentifier category:@"zdlog"];
    });
    return instance;
}

- (instancetype)initWithSubsystem:(NSString *)subsystem category:(NSString *)category {
    if (self = [super init]) {
        _subsystem = subsystem;
        _category = category;
    }
    return self;
}

- (void)logWithType:(os_log_type_t)type message:(id)msg {
    if (!msg) {
        return;
    }
    
    switch (type) {
        case OS_LOG_TYPE_INFO:
            os_log_info(self.osLog, "%@", msg);
            break;
        case OS_LOG_TYPE_DEBUG:
            os_log_debug(self.osLog, "%@", msg);
            break;
        case OS_LOG_TYPE_ERROR:
            os_log_error(self.osLog, "%@", msg);
            break;
        case OS_LOG_TYPE_FAULT:
            os_log_fault(self.osLog, "%@", msg);
            break;
        default:
            os_log(self.osLog, "%@", msg);
            break;
    }
}

#pragma mark - Getter

- (os_log_t)osLog {
    if (!_osLog) {
        static os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
        os_unfair_lock_lock(&lock);
        _osLog = [self getLogger];
        os_unfair_lock_unlock(&lock);
    }
    return _osLog;
}

- (os_log_t)getLogger {
    if (self.subsystem == nil || self.category == nil) {
        return OS_LOG_DEFAULT;
    }
    
    const char *subsystem = self.subsystem.UTF8String;
    const char *category = self.category.UTF8String;
    os_log_t log = os_log_create(subsystem, category);
    
    return log;
}

@end
