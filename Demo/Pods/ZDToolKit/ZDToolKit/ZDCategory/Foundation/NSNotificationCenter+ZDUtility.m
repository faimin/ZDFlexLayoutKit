//
//  NSNotificationCenter+ZDUtility.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/10/12.
//

#import "NSNotificationCenter+ZDUtility.h"
@import ObjectiveC;

@interface ZDNotificationToken : NSObject
@property (nonatomic, weak) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) id<NSObject> observer;
@end

@implementation ZDNotificationToken

- (void)dealloc {
    if (self.observer) {
        [self.notificationCenter removeObserver:self.observer];
        _observer = nil;
    }
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)center observer:(id)observer {
    if (self = [super init]) {
        _notificationCenter = center;
        _observer = observer;
    }
    return self;
}

@end

//---------------------------------------------------------------------

@implementation NSNotificationCenter (ZDUtility)

- (void)zd_addObserverForName:(NSNotificationName)name object:(id)obj queue:(NSOperationQueue *)queue receiver:(id)virtualObserver usingBlock:(void (^)(NSNotification * _Nonnull))block {
    id<NSObject> revealObserver = [self addObserverForName:name object:obj queue:queue usingBlock:block];
    ZDNotificationToken *token = [[ZDNotificationToken alloc] initWithNotificationCenter:self observer:revealObserver];
    objc_setAssociatedObject(virtualObserver, (__bridge const void * _Nonnull)(name), token, OBJC_ASSOCIATION_RETAIN);
}

@end
