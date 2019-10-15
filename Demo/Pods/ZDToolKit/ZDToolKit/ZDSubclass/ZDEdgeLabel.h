//
//  ZDEdgeLabel.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 16/9/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZDAlignment) {
    ZDAlignment_Middle = 0,
    ZDAlignment_Top,
    ZDAlignment_Bottom,
};

@interface ZDEdgeLabel : UILabel

///  设置文字在label中的边距（上、左、下、右）;
///  @discussion 设置此属性后需要设置[self.label sizeToFit]
///  @waring 这个属性与添加事件冲突
@property (nonatomic, assign) UIEdgeInsets zd_edgeInsets;

/// 默认居中显示
@property (nonatomic, assign) ZDAlignment zdAlignment;

@end

NS_ASSUME_NONNULL_END
