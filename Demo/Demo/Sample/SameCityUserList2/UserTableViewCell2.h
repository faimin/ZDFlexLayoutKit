//
//  UserTableViewCell2.h
//  Demo
//
//  Created by Zero.D.Saber on 2022/02/27.
//  Copyright © 2022 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ZDFlexLayoutKit;

NS_ASSUME_NONNULL_BEGIN

@class UserModel;
@interface UserTableViewCell2 : ZDFlexLayoutTableViewCell

@property (nonatomic, strong) UserModel *model;

@end

NS_ASSUME_NONNULL_END
