//
//  UIResponder+ZDUtility.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (ZDUtility)

- (void)zd_deliverEventWithName:(NSString *)eventName parameters:(NSDictionary *_Nullable)paramsDict;

@end

NS_ASSUME_NONNULL_END
