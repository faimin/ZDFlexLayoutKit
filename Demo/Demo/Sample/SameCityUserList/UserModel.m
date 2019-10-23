//
//  UserModel.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@end

@implementation UserModelList

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
             @"list" : UserModel.class
             };
}

@end
