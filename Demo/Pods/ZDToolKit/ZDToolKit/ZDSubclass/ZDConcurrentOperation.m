//
//  ZDConcurrentOperation.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/5/11.
//

#import "ZDConcurrentOperation.h"

typedef NS_ENUM(NSInteger, ZDOperationState) {
    ZDOperationState_Ready      = 0,
    ZDOperationState_Executing  = 1,
    ZDOperationState_Finished   = 2,
};

@interface ZDConcurrentOperation ()
@property (nonatomic, assign) ZDOperationState state;
@property (nonatomic, copy) ZDOperationTaskBlock taskBlock;
@end

@implementation ZDConcurrentOperation

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

+ (instancetype)operationWithBlock:(ZDOperationTaskBlock)taskBlock {
    ZDConcurrentOperation *op = [[ZDConcurrentOperation alloc] init];
    op->_taskBlock = [taskBlock copy];
    op->_state = ZDOperationState_Ready;
    return op;
}

#pragma mark - Override OP Method

- (void)main {
    __weak typeof(self) weakSelf = self;
    ZDTaskOnComplteBlock onCompleteBlock = ^(BOOL isTaskFinished){
        __strong typeof(weakSelf) self = weakSelf;
        if (!isTaskFinished) return;
        self.state = ZDOperationState_Finished;
    };
    self.taskBlock(onCompleteBlock);
    self.state = ZDOperationState_Executing;
}

- (void)start {
    if (self.isCancelled) return;
    if (!self.taskBlock) return;
    
    [self main];
}

- (void)cancel {
    if (self.isCancelled || self.isFinished) {
        return;
    }
    
    [super cancel];
    self.taskBlock = nil;
    self.state = ZDOperationState_Finished;
}

#pragma mark - Override State

- (BOOL)isReady {
    return self.state == ZDOperationState_Ready && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == ZDOperationState_Executing;
}

- (BOOL)isFinished {
    return self.state == ZDOperationState_Finished;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark - Private

static NSString *StateKey(ZDOperationState state) {
    NSString *key = nil;
    switch (state) {
        case ZDOperationState_Ready: {
            key = NSStringFromSelector(@selector(isReady));
        } break;
        case ZDOperationState_Executing: {
            key = NSStringFromSelector(@selector(isExecuting));
        } break;
        case ZDOperationState_Finished: {
            key = NSStringFromSelector(@selector(isFinished));
        } break;
        default: {
            key = NSStringFromSelector(@selector(state));
        } break;
    }
    return key;
}

#pragma mark - Setter

- (void)setState:(ZDOperationState)state {
    if (_state == state) return;
    
    NSString *newKey = StateKey(state);
    NSString *oldKey = StateKey(_state);
    
    [self willChangeValueForKey:newKey];
    [self willChangeValueForKey:oldKey];
    _state = state;
    [self didChangeValueForKey:newKey];
    [self didChangeValueForKey:oldKey];
}

@end
