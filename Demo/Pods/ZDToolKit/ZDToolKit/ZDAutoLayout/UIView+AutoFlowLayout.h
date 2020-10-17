// UIView+AutoLayout.h
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

#import <UIKit/UIKit.h>

#pragma clang diagnostic ignored "-Wstrict-prototypes"

/**
 *  AutoLayout abstract item
 */
typedef struct ALMargin {
    /**
     *  Leading space to superview
     */
    CGFloat LeftMargin;
    
    /**
     *  Trailing space to superview
     */
    CGFloat RightMargin;
    
    /**
     *  Top space to superview
     */
    CGFloat TopMargin;
    
    /**
     *  Bottom space to superview
     */
    CGFloat BottomMargin;
    
}ALMargin;

/* Make a margin from `(left, right, top, bottom)'. */
UIKIT_EXTERN ALMargin ALMarginMake(CGFloat l, CGFloat r, CGFloat t, CGFloat b);

/* Make a margin from `(left, 0, 0, 0)'. */
UIKIT_EXTERN ALMargin ALMarginMakeLeft(CGFloat l);

/* Make a margin from `(0, right, 0, 0)'. */
UIKIT_EXTERN ALMargin ALMarginMakeRight(CGFloat r);

/* Make a margin from `(0, 0, top, 0)'. */
UIKIT_EXTERN ALMargin ALMarginMakeTop(CGFloat t);

/* Make a margin from `(0, 0, 0, bottom)'. */
UIKIT_EXTERN ALMargin ALMarginMakeBottom(CGFloat b);

/* Make a margin from `(0, 0, 0, 0)'. */
UIKIT_EXTERN ALMargin ALMarginZero();

/**
 *  Flow layout direction
 */
typedef NS_ENUM(NSInteger, ALLayoutDirection){
    /**
     *  None
     */
    ALLayoutDirectionNone,
    /**
     *  Horizontal Flow Layout
     */
    ALLayoutDirectionHorizontal,
    /**
     *  Vertical Flow Layout
     */
    ALLayoutDirectionVertical
};

@interface UIView (AutoFlowLayout)

/** ======================================================================== **
 ** These  APIs have implemented Method `addSubview` for instance of UIView  **
 ** ======================================================================== **/

/**
 *  Add one view as subview using `ALMargin` to control AutoLayout.
 *
 *
 *  @param view     The view to be added. After being added, this view appears on top of any other subviews and auto layout by `margin` param.
 *  @param margin   Item of `ALMargin`, the item must confirm the view's four Constrant `Leading space`,`Trailing space`,`Top scpace` and `Bottom space`.
 */
- (void)addSubview:(UIView *)view fillByMargin:(ALMargin)margin;

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview fillByMargin:(ALMargin)margin;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index fillByMargin:(ALMargin)margin;
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview fillByMargin:(ALMargin)margin;

/**
 *  Add subviews by Flow Layout
 *
 *  @param views        The views to added.
 *  @param direction    Flow layout direction.
 *  @param margin       Consider all view as one view on the superview (This method set interval bettween views as `ZERO`), and make a sute margin item.
 */
- (void)addSubviews:(NSArray *)views flowLayoutDirection:(ALLayoutDirection)direction fillByMargin:(ALMargin )margin;

/**
 *  Add subviews by Flow Layout
 *
 *  @param views     The views to added.
 *  @param direction Flow layout direction.
 *  @param margin    Consider all view as one view on the superview, and make a sute margin item.
 *  @param interval  Interval bettween views
 */
- (void)addSubviews:(NSArray *)views flowLayoutDirection:(ALLayoutDirection)direction fillByMargin:(ALMargin)margin interval:(CGFloat)interval;

@end

