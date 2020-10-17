// UIView+AutoLayout.m
// Copyright (c) 2014–2015 xincc (https://github.com/xincc)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "UIView+AutoFlowLayout.h"

ALMargin ALMarginMake(CGFloat l,CGFloat r, CGFloat t, CGFloat b){
    ALMargin  res ;
    res.LeftMargin = l;
    res.RightMargin = r;
    res.TopMargin = t;
    res.BottomMargin = b;
    return res;
};

ALMargin ALMarginMakeLeft(CGFloat l) {
    return ALMarginMake(l, 0.f, 0.f, 0.f);
}
ALMargin  ALMarginMakeRight(CGFloat r) {
    return ALMarginMake(0.f, r, 0.f, 0.f);
}
ALMargin  ALMarginMakeTop(CGFloat t) {
    return ALMarginMake(0.f, 0.f, t, 0.f);
}
ALMargin  ALMarginMakeBottom(CGFloat b) {
    return ALMarginMake(0.f, 0.f, 0.f, b);
}
ALMargin  ALMarginZero(){
    return ALMarginMake(0.f, 0.f, 0.f, 0.f);
}


@implementation UIView (AutoFlowLayout)


#pragma mark -
#pragma mark - Tools


UIKIT_STATIC_INLINE void cleanRemoveFromSuperview(UIView * view ) {
    
    view.translatesAutoresizingMaskIntoConstraints = NO;

    if(!view || !view.superview) return;

    [view layoutIfNeeded];
    
    //clear superview's constrants related self
    NSMutableArray * constraints_to_remove = [NSMutableArray new];
    UIView * superview = view.superview;
    
    for( NSLayoutConstraint * constraint in superview.constraints) {
        if( constraint.firstItem == view || constraint.secondItem == view ) {
            [constraints_to_remove addObject:constraint];
        }
    }
    [superview removeConstraints:constraints_to_remove];
    
    //clear self's constrants
    [view removeFromSuperview];
}


- (void)addConstraintToView:(UIView*)view withMargin:(ALMargin)margin
{
    NSDictionary * dic     = @{@"view":view};

    NSDictionary * metrics = @{@"left":     @(margin.LeftMargin),
                               @"right":    @(margin.RightMargin),
                               @"top":      @(margin.TopMargin),
                               @"bottom":   @(margin.BottomMargin)};
    
    NSString * formatH = [NSString stringWithFormat:@""];
    NSString * formatV = [NSString stringWithFormat:@""];

    if ([self isKindOfClass:UIScrollView.class]) {
        [self layoutIfNeeded];
        
        // [!] NOT RECOMMEND using this method to layout subviews of UIScrollView.
        // [!] Infact, the scrollview will behaviour as a UIView except seting ContentSize manually.
        // [!] Make sure the scrollview can layout with a determinate bounds.
        // [!] Maybe you should add it to it's super view first.
        
        NSAssert(CGRectGetHeight(self.bounds)&&CGRectGetWidth(self.bounds), @"CCAutoLayout Error: Require superview's bounds.");
        
        formatH = [NSString stringWithFormat:@"|-left-[view(%f@%f)]-right-|",CGRectGetWidth(self.bounds)-margin.LeftMargin-margin.RightMargin,UILayoutPriorityDefaultHigh];
        formatV = [NSString stringWithFormat:@"V:|-top-[view(%f@%f)]-bottom-|",CGRectGetHeight(self.bounds)-margin.TopMargin-margin.BottomMargin,UILayoutPriorityDefaultHigh];

    } else {
        formatH = @"|-left-[view]-right-|";
        formatV = @"V:|-top-[view]-bottom-|";
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatH options:0 metrics:metrics views:dic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatV options:0 metrics:metrics views:dic]];
}


#pragma mark -
#pragma mark - Fill Layout

- (void)addSubview:(UIView*)view fillByMargin:(ALMargin)margin
{
    cleanRemoveFromSuperview(view);
    [self addSubview:view];
    [self addConstraintToView:view withMargin:margin];
}
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index fillByMargin:(ALMargin)margin
{
    cleanRemoveFromSuperview(view);
    [self insertSubview:view atIndex:index];
    [self addConstraintToView:view withMargin:margin];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview fillByMargin:(ALMargin)margin
{
    cleanRemoveFromSuperview(view);
    [self insertSubview:view aboveSubview:siblingSubview];
    [self addConstraintToView:view withMargin:margin];
}
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview fillByMargin:(ALMargin)margin
{
    cleanRemoveFromSuperview(view);
    [self insertSubview:view belowSubview:siblingSubview];
    [self addConstraintToView:view withMargin:margin];
}

#pragma mark -
#pragma mark - Flow Layout


- (void)addSubviews:(NSArray*)views flowLayoutDirection:(ALLayoutDirection)direction fillByMargin:(ALMargin )margin interval:(CGFloat)interval
{
    if (![views.firstObject isKindOfClass:UIView.class]) {
        NSLog(@"CCAutoLayout Error: items should be kind of UIView object and can not be nil");
        return;
    }
    NSMutableDictionary * items = [NSMutableDictionary dictionary];
    NSMutableString * formartH  = [NSMutableString stringWithFormat:@""];
    NSMutableString * formartV  = [NSMutableString stringWithFormat:@""];
    
    //get layout data
    NSMutableArray *orderedKey = [NSMutableArray arrayWithCapacity:views.count];
    for (NSUInteger i = 0; i < views.count; i++) {
        UIView *value = views[i];
        cleanRemoveFromSuperview(value);
        [self addSubview:value];
        NSString *key = [NSString stringWithFormat:@"%@%lu", @"view", (unsigned long)i];
        [items setValue:value forKey:key];
        [orderedKey addObject:key];
    }
    
    NSDictionary * metrics = @{@"left":     @(margin.LeftMargin),
                               @"right":    @(margin.RightMargin),
                               @"top":      @(margin.TopMargin),
                               @"bottom":   @(margin.BottomMargin)};
    
    //config VFL
    
    if (direction == ALLayoutDirectionHorizontal) {
        //Horizontal flow layout
        
        //`leading`,`top`,`bottom` space to super view for first view
        [formartH appendFormat:@"|-left-[%@]",orderedKey.firstObject];
        formartV = [NSMutableString stringWithFormat:@"V:|-top-[%@]-bottom-|",orderedKey.firstObject];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formartV options:0 metrics:metrics views:items]];
        
        //`top`,`buttom` space to super view for each subview except first view
        for (int i = 1; i < orderedKey.count; i++) {
            [formartH appendFormat:@"-(%f)-[%@(==%@)]",interval,orderedKey[i],orderedKey[i-1]];
            formartV = [NSMutableString stringWithFormat:@"V:|-top-[%@]-bottom-|",orderedKey[i]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formartV options:0 metrics:metrics views:items]];
        }
        
        //`trailing` space to superview for last view
        [formartH appendString:@"-right-|"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formartH options:0 metrics:metrics views:items]];
        
    } else if (direction == ALLayoutDirectionVertical){
        //Vertical flow layout
        
        //`top`,`leading`,`trailing` space to superview for first view
        [formartV appendFormat:@"V:|-top-[%@]",orderedKey.firstObject];
        formartH = [NSMutableString stringWithFormat:@"|-left-[%@]-right-|",orderedKey.firstObject];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formartH options:0 metrics:metrics views:items]];
        
        //leading & trailing space to superview for each subview except first view
        for (int i = 1; i < orderedKey.count; i++) {
            [formartV appendFormat:@"-(%f)-[%@(==%@)]",interval,orderedKey[i],orderedKey[i-1]];
            formartH = [NSMutableString stringWithFormat:@"|-left-[%@]-right-|",orderedKey[i]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formartH options:0 metrics:metrics views:items]];
        }
        
        //`bottom` space to superview for last view
        [formartV appendString:@"-bottom-|"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formartV options:0 metrics:metrics views:items]];
    } else {
        
    }

}

- (void)addSubviews:(NSArray*)views flowLayoutDirection:(ALLayoutDirection)direction fillByMargin:(ALMargin )margin
{
    [self addSubviews:views flowLayoutDirection:direction fillByMargin:margin interval:0.f];
}


@end

