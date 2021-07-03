//
//  UserModel.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *s_city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *list_show_text;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger is_match_maker;
@property (nonatomic, assign) NSInteger is_mic;
@property (nonatomic, copy) NSString *job;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *online_time;
@property (nonatomic, copy) NSString *s_province;
@property (nonatomic, copy) NSString *marry_declare;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *logid;
@property (nonatomic, assign) BOOL lover_setting;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *income;
@property (nonatomic, assign) NSInteger fortune;
@property (nonatomic, copy) NSString *condition_age;

@property (nonatomic, assign) BOOL flag;

@end

@interface UserModelList : NSObject

@property (nonatomic, strong) NSArray<UserModel *> *list;

@end

NS_ASSUME_NONNULL_END

