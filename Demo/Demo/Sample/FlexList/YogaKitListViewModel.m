//
//  YogaKitListViewModel.m
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/12/12.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "YogaKitListViewModel.h"
#import <YYModel/YYModel.h>

@implementation YogaKitListViewModel

+ (NSArray<TextureModel *> *)yogaListModels {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:resourcePath];
    TextureModelList *list = [TextureModelList yy_modelWithJSON:jsonData];
    NSArray<TextureModel *> *textureModels = list.feed;
    return textureModels;
}


@end
