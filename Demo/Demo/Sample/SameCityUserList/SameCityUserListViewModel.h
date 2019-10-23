//
//  SameCityUserListViewModel.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UserModel;
@interface SameCityUserListViewModel : NSObject

+ (NSArray<UserModel *> *)userListModels;

@end

NS_ASSUME_NONNULL_END
