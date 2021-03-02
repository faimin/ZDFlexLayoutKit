//
//  ZDBackgroundContainerView.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/2/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDBackgroundContainerView : UIView

@property (nonatomic, copy) void(^tapActionBlock)(__kindof __unsafe_unretained ZDBackgroundContainerView *containerView);

@end

NS_ASSUME_NONNULL_END
