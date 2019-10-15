//
//  ZDDispatchSourceMerge.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MDDispatchSourceMergeType) {
    MDDispatchSourceMergeType_NULL,
    MDDispatchSourceMergeType_UI,
    MDDispatchSourceMergeType_DATA,
};

@protocol ZDDispatchSourceMergeDelegate <NSObject>
@optional
- (void)refreshUI;
- (void)refreshData;
@end

@interface ZDDispatchSourceMerge : NSObject

@property (nonatomic, weak, readonly) id<ZDDispatchSourceMergeDelegate> delegate;

- (instancetype)initWithSourceType:(MDDispatchSourceMergeType)type onQueue:(nullable dispatch_queue_t)onQueue delegate:(id<ZDDispatchSourceMergeDelegate>)delegate;

- (void)merge;

- (void)clearSource;

@end

NS_ASSUME_NONNULL_END

