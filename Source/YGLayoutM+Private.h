/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the LICENSE
 * file in the root directory of this source tree.
 */
#import "YGLayoutM.h"
#import <yoga/Yoga.h>
#import "ZDFlexLayoutDivProtocol.h"

@interface YGLayoutM ()

@property (nonatomic, assign, readonly) YGNodeRef node;

- (instancetype)initWithView:(ZDFlexLayoutView)view;

@end
