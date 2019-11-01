//
//  UIScrollView+ZDFlexLayout.h
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/26.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDFlexLayoutDivProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (ZDFlexLayout)

@property (nonatomic, strong, readonly) ZDFlexLayoutView zd_contentView;

- (BOOL)zd_initedContentView;

@end

NS_ASSUME_NONNULL_END
