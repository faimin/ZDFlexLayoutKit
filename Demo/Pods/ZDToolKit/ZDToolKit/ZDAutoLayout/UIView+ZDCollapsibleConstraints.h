//
//  UIView+ZDCollapsibleConstraints.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZDCollapsibleConstraints)

- (void)zd_hideWithAutoLayoutAttributes:(NSLayoutAttribute)attributes, ... NS_REQUIRES_NIL_TERMINATION;

- (nullable NSLayoutConstraint *)zd_constraintForAttribute:(NSLayoutAttribute)attribute;

@end

NS_ASSUME_NONNULL_END
