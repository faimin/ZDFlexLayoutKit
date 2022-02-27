//
//  ZDFlexLayoutTableViewCell.h
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/5/22.
//
//  继承此Cell，开启autolayout自动算高的设置后也可以自动计算高度

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDFlexLayoutTableViewCell : UITableViewCell

/// default is NO
- (BOOL)autoRefreshLayout;

@end

NS_ASSUME_NONNULL_END
