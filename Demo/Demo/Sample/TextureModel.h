//
//  TextureModel.h
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/10/23.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@interface TextureModel : NSObject
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *time;
@end

@interface TextureModelList : NSObject <YYModel>
@property (nonatomic, strong) NSArray<TextureModel *> *feed;
@end


