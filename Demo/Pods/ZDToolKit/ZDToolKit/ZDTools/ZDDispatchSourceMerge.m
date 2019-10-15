//
//  ZDDispatchSourceMerge.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/5/18.
//

#import "ZDDispatchSourceMerge.h"

struct ZDDelegateRespondTo {
    uint refreshUI : 1;
    uint refreshData : 1;
};

@interface ZDDispatchSourceMerge ()
@property (nonatomic, strong) dispatch_source_t mergeDataSource;
@property (nonatomic, assign) MDDispatchSourceMergeType sourceType;
@property (nonatomic, strong) dispatch_queue_t targetQueue;
@property (nonatomic, assign) struct ZDDelegateRespondTo delegateRespondsTo;
@property (nonatomic, weak) id<ZDDispatchSourceMergeDelegate> delegate;
@end

@implementation ZDDispatchSourceMerge

- (void)dealloc {
    [self clearSource];
}

- (instancetype)initWithSourceType:(MDDispatchSourceMergeType)type onQueue:(dispatch_queue_t)onQueue delegate:(id<ZDDispatchSourceMergeDelegate>)delegate {
    if (self = [super init]) {
        _sourceType = type;
        _targetQueue = onQueue;
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (void)setup {
    [self delegateRespond];
    [self setupDispatchSource];
}

- (void)delegateRespond {
    struct ZDDelegateRespondTo newResponse;
    newResponse.refreshUI = [self.delegate respondsToSelector:@selector(refreshUI)];
    newResponse.refreshData = [self.delegate respondsToSelector:@selector(refreshData)];
    self.delegateRespondsTo = newResponse;
}

- (void)setupDispatchSource {
    dispatch_queue_t queue = self.targetQueue ?: dispatch_get_main_queue();
    _mergeDataSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, queue);
    
    dispatch_source_set_event_handler(_mergeDataSource, ^{
        NSLog(@"dispatch_source_get_data: %lu", dispatch_source_get_data(self.mergeDataSource));
        [self handleEvent];
    });
    
    dispatch_source_set_cancel_handler(_mergeDataSource, ^{
        NSLog(@"dispatch source canceled");
    });

    dispatch_resume(_mergeDataSource);
}

- (void)handleEvent {
    switch (self.sourceType) {
        case MDDispatchSourceMergeType_NULL:
        case MDDispatchSourceMergeType_UI:
        {
            if (self.delegateRespondsTo.refreshUI) {
                [self.delegate refreshUI];
            }
        }
            break;
        
        case MDDispatchSourceMergeType_DATA:
        {
            if (self.delegateRespondsTo.refreshData) {
                [self.delegate refreshData];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)merge {
    if (!_mergeDataSource) return;
    
    dispatch_source_merge_data(_mergeDataSource, 1);
}

- (void)clearSource {
    if (_mergeDataSource) {
        dispatch_source_cancel(_mergeDataSource);
        _mergeDataSource = nil;
    }
    _delegate = nil;
}

@end
