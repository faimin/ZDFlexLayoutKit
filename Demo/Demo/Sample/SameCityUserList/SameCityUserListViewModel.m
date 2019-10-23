//
//  SameCityUserListViewModel.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "SameCityUserListViewModel.h"
#import <YYModel/YYModel.h>
#import "UserModel.h"

@implementation SameCityUserListViewModel

+ (NSArray<UserModel *> *)userListModels {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"same_city_users" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:resourcePath];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingFragmentsAllowed error:nil];
    UserModelList *list = [UserModelList yy_modelWithJSON:jsonDict[@"data"]];
    NSArray<UserModel *> *userModels = list.list;
    return userModels;
}

@end
