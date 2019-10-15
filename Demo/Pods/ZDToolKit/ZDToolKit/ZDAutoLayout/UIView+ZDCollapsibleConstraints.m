//
//  UIView+ZDCollapsibleConstraints.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/9/21.
//

#import "UIView+ZDCollapsibleConstraints.h"
#import <objc/runtime.h>

@implementation UIView (ZDCollapsibleConstraints)

- (void)zd_hideWithAutoLayoutAttributes:(NSLayoutAttribute)attributes, ... NS_REQUIRES_NIL_TERMINATION {
    va_list ap;
    va_start(ap, attributes);
    
    if (attributes) {
        [self zd_hideView:!self.hidden withAttribute:attributes];
        
        NSLayoutAttribute detailAttribute;
        while ( (detailAttribute = va_arg(ap, NSLayoutAttribute)) ) {
            [self zd_hideView:!self.hidden withAttribute:detailAttribute];
        }
    }
    
    va_end(ap);
    self.hidden = !self.hidden;
}

- (void)zd_hideView:(BOOL)hidden withAttribute:(NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [self zd_constraintForAttribute:attribute];
    if (constraint) {
        NSString *constraintString = [self zd_attributeToString:attribute];
        NSNumber *savedNumber = objc_getAssociatedObject(self, [constraintString UTF8String]);
        
        if (!savedNumber) {
            objc_setAssociatedObject(self, [constraintString UTF8String], @(constraint.constant), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            savedNumber = @(constraint.constant);
        }
        
        constraint.constant = hidden ? 0.0 : savedNumber.floatValue;
    }
}

- (CGFloat)constraintConstantforAttribute:(NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [self zd_constraintForAttribute:attribute];
    if (constraint) {
        return constraint.constant;
    }
    else {
        return NAN;
    }
}

- (NSLayoutConstraint *)zd_constraintForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d && firstItem = %@", attribute, self];
    NSArray<__kindof NSLayoutConstraint *> *constraintsArray = [self.superview constraints];
    NSArray<__kindof NSLayoutConstraint *> *fillteredArray = [constraintsArray filteredArrayUsingPredicate:predicate];
    
    if (fillteredArray.count > 0) {
        return fillteredArray.firstObject;
    }
    else {
        NSArray<__kindof NSLayoutConstraint *> *selfFillteredArray = [self.constraints filteredArrayUsingPredicate:predicate];
        return selfFillteredArray.firstObject;
    }
}

- (NSString *)zd_attributeToString:(NSLayoutAttribute)attribute {
    switch (attribute) {
        case NSLayoutAttributeLeft:
        {
            return @"NSLayoutAttributeLeft";
        }
            
        case NSLayoutAttributeRight:
        {
            return @"NSLayoutAttributeRight";
        }
            
        case NSLayoutAttributeTop:
        {
            return @"NSLayoutAttributeTop";
        }
            
        case NSLayoutAttributeBottom:
        {
            return @"NSLayoutAttributeBottom";
        }
            
        case NSLayoutAttributeLeading:
        {
            return @"NSLayoutAttributeLeading";
        }
            
        case NSLayoutAttributeTrailing:
        {
            return @"NSLayoutAttributeTrailing";
        }
            
        case NSLayoutAttributeWidth:
        {
            return @"NSLayoutAttributeWidth";
        }
            
        case NSLayoutAttributeHeight:
        {
            return @"NSLayoutAttributeHeight";
        }
            
        case NSLayoutAttributeCenterX:
        {
            return @"NSLayoutAttributeCenterX";
        }
            
        case NSLayoutAttributeCenterY:
        {
            return @"NSLayoutAttributeCenterY";
        }
            
        case NSLayoutAttributeBaseline:
        {
            return @"NSLayoutAttributeBaseline";
        }
            
        case NSLayoutAttributeFirstBaseline:
        {
            return @"NSLayoutAttributeFirstBaseline";
        }
            
        case NSLayoutAttributeLeftMargin:
        {
            return @"NSLayoutAttributeLeftMargin";
        }
            
        case NSLayoutAttributeRightMargin:
        {
            return @"NSLayoutAttributeRightMargin";
        }
            
        case NSLayoutAttributeTopMargin:
        {
            return @"NSLayoutAttributeTopMargin";
        }
            
        case NSLayoutAttributeBottomMargin:
        {
            return @"NSLayoutAttributeBottomMargin";
        }
            
        case NSLayoutAttributeLeadingMargin:
        {
            return @"NSLayoutAttributeLeadingMargin";
        }
            
        case NSLayoutAttributeTrailingMargin:
        {
            return @"NSLayoutAttributeTrailingMargin";
        }
            
        case NSLayoutAttributeCenterXWithinMargins:
        {
            return @"NSLayoutAttributeCenterXWithinMargins";
        }
            
        case NSLayoutAttributeCenterYWithinMargins:
        {
            return @"NSLayoutAttributeCenterYWithinMargins";
        }
            
        case NSLayoutAttributeNotAnAttribute:
        {
            return @"NSLayoutAttributeNotAnAttribute";
        }
            
        default:
            break;
    }
    
    return @"NSLayoutAttributeNotAnAttribute";
}

@end
