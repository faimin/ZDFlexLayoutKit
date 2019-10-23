//
//  UserTableViewCell.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, strong) UserModel *model;

@end

NS_ASSUME_NONNULL_END
