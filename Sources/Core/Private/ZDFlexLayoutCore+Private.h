/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the LICENSE
 * file in the root directory of this source tree.
 */
#import "ZDFlexLayoutCore.h"
#import <yoga/Yoga.h>
#import "ZDFlexLayoutViewProtocol.h"

@interface ZDFlexLayoutCore ()

@property (nonatomic, assign, readonly) YGNodeRef node;

- (instancetype)initWithView:(ZDFlexLayoutView)view;

@end
