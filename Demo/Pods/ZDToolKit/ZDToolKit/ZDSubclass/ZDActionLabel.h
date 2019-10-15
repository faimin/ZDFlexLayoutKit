//
//  ZDLabel.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDActionLabel : UILabel

///  给指定文字添加点击事件
///  @param target 执行事件的目标对象
///  @param action 选择子(暂时还不支持携带参数)
///  @param params 参数数组(暂不支持block类型的参数)
///  @param ranges 要响应事件的文字的所在的range数组
- (void)addTarget:(id)target
           action:(SEL)action
           params:(nullable NSArray *)params
           ranges:(NSArray<NSValue *> *)ranges;

@end

NS_ASSUME_NONNULL_END
