//
//  TextureModel.m
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/10/23.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "TextureModel.h"

@implementation TextureModel

@end

@implementation TextureModelList

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
             @"feed" : TextureModel.class
             };
}

@end
