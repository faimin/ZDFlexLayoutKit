//
//  UIResponder+ZDUtility.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/10/15.
//

#import "UIResponder+ZDUtility.h"

@implementation UIResponder (ZDUtility)

- (void)zd_deliverEventWithName:(NSString *)eventName parameters:(NSDictionary *)paramsDict {
    if (!eventName || eventName.length == 0) return;
    
    [[self nextResponder] zd_deliverEventWithName:eventName parameters:paramsDict];
}

@end
