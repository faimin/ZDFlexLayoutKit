//
//  ZDConcurrentOperation.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZDTaskOnComplteBlock)(BOOL);
typedef void(^ZDOperationTaskBlock)(ZDTaskOnComplteBlock);

@interface ZDConcurrentOperation : NSOperation

+ (instancetype)operationWithBlock:(ZDOperationTaskBlock)block;

@end

NS_ASSUME_NONNULL_END
