/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the LICENSE
 * file in the root directory of this source tree.
 */

#import "ZDFlexLayoutCore.h"
#import "ZDFlexLayoutViewProtocol.h"

@interface ZDFlexLayoutCore ()

@property (nonatomic, assign, readonly) YGNodeRef node;

- (instancetype)initWithView:(ZDFlexLayoutView)view;

/// Must be called on main thread — reads UIView.traitCollection
- (void)updateLayoutDirectionIfNeeded;

/// Calculate layout with optional async mode (pre-measures leaf nodes, skips measure func)
- (CGSize)calculateLayoutWithSize:(CGSize)size asyncMode:(BOOL)asyncMode;

@end
