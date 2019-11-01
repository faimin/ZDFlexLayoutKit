/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ZDFlexLayout+Private.h"
#import <objc/runtime.h>
#import "ZDCalculateHelper.h"
#import "UIScrollView+ZDFlexLayout.h"

#define YG_PROPERTY(type, lowercased_name, capitalized_name)    \
- (type)lowercased_name                                         \
{                                                               \
  return YGNodeStyleGet##capitalized_name(self.node);           \
}                                                               \
                                                                \
- (void)set##capitalized_name:(type)lowercased_name             \
{                                                               \
  YGNodeStyleSet##capitalized_name(self.node, lowercased_name); \
}

#define YG_VALUE_PROPERTY(lowercased_name, capitalized_name)                       \
- (YGValue)lowercased_name                                                         \
{                                                                                  \
  return YGNodeStyleGet##capitalized_name(self.node);                              \
}                                                                                  \
                                                                                   \
- (void)set##capitalized_name:(YGValue)lowercased_name                             \
{                                                                                  \
  switch (lowercased_name.unit) {                                                  \
     case YGUnitUndefined:                                                         \
      YGNodeStyleSet##capitalized_name(self.node, lowercased_name.value);          \
      break;                                                                       \
    case YGUnitPoint:                                                              \
      YGNodeStyleSet##capitalized_name(self.node, lowercased_name.value);          \
      break;                                                                       \
    case YGUnitPercent:                                                            \
      YGNodeStyleSet##capitalized_name##Percent(self.node, lowercased_name.value); \
      break;                                                                       \
    default:                                                                       \
      NSAssert(NO, @"Not implemented");                                            \
  }                                                                                \
}

#define YG_AUTO_VALUE_PROPERTY(lowercased_name, capitalized_name)                  \
- (YGValue)lowercased_name                                                         \
{                                                                                  \
  return YGNodeStyleGet##capitalized_name(self.node);                              \
}                                                                                  \
                                                                                   \
- (void)set##capitalized_name:(YGValue)lowercased_name                             \
{                                                                                  \
  switch (lowercased_name.unit) {                                                  \
    case YGUnitPoint:                                                              \
      YGNodeStyleSet##capitalized_name(self.node, lowercased_name.value);          \
      break;                                                                       \
    case YGUnitPercent:                                                            \
      YGNodeStyleSet##capitalized_name##Percent(self.node, lowercased_name.value); \
      break;                                                                       \
    case YGUnitAuto:                                                               \
      YGNodeStyleSet##capitalized_name##Auto(self.node);                           \
      break;                                                                       \
    default:                                                                       \
      NSAssert(NO, @"Not implemented");                                            \
  }                                                                                \
}

#define YG_EDGE_PROPERTY_GETTER(type, lowercased_name, capitalized_name, property, edge) \
- (type)lowercased_name                                                                  \
{                                                                                        \
  return YGNodeStyleGet##property(self.node, edge);                                      \
}

#define YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge) \
- (void)set##capitalized_name:(CGFloat)lowercased_name                             \
{                                                                                  \
  YGNodeStyleSet##property(self.node, edge, lowercased_name);                      \
}

#define YG_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge)         \
YG_EDGE_PROPERTY_GETTER(CGFloat, lowercased_name, capitalized_name, property, edge) \
YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGE_PROPERTY_SETTER(objc_lowercased_name, objc_capitalized_name, c_name, edge) \
- (void)set##objc_capitalized_name:(YGValue)objc_lowercased_name                                 \
{                                                                                                \
  switch (objc_lowercased_name.unit) {                                                           \
    case YGUnitUndefined:                                                                        \
      YGNodeStyleSet##c_name(self.node, edge, objc_lowercased_name.value);                       \
      break;                                                                                     \
    case YGUnitPoint:                                                                            \
      YGNodeStyleSet##c_name(self.node, edge, objc_lowercased_name.value);                       \
      break;                                                                                     \
    case YGUnitPercent:                                                                          \
      YGNodeStyleSet##c_name##Percent(self.node, edge, objc_lowercased_name.value);              \
      break;                                                                                     \
    default:                                                                                     \
      NSAssert(NO, @"Not implemented");                                                          \
  }                                                                                              \
}

#define YG_VALUE_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge)   \
YG_EDGE_PROPERTY_GETTER(YGValue, lowercased_name, capitalized_name, property, edge) \
YG_VALUE_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGES_PROPERTIES(lowercased_name, capitalized_name)                                                  \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Left, capitalized_name##Left, capitalized_name, YGEdgeLeft)                   \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Top, capitalized_name##Top, capitalized_name, YGEdgeTop)                      \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Right, capitalized_name##Right, capitalized_name, YGEdgeRight)                \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Bottom, capitalized_name##Bottom, capitalized_name, YGEdgeBottom)             \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Start, capitalized_name##Start, capitalized_name, YGEdgeStart)                \
YG_VALUE_EDGE_PROPERTY(lowercased_name##End, capitalized_name##End, capitalized_name, YGEdgeEnd)                      \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Horizontal, capitalized_name##Horizontal, capitalized_name, YGEdgeHorizontal) \
YG_VALUE_EDGE_PROPERTY(lowercased_name##Vertical, capitalized_name##Vertical, capitalized_name, YGEdgeVertical)       \
YG_VALUE_EDGE_PROPERTY(lowercased_name, capitalized_name, capitalized_name, YGEdgeAll)

#if !INCLUDE_UIVIEW_YOGA
YGValue YGPointValue(CGFloat value)
{
  return (YGValue) { .value = value, .unit = YGUnitPoint };
}

YGValue YGPercentValue(CGFloat value)
{
  return (YGValue) { .value = value, .unit = YGUnitPercent };
}
#endif

static YGConfigRef globalConfig;

@interface ZDFlexLayout ()

@property (nonatomic, weak, readonly) ZDFlexLayoutView view;
@property (nonatomic, assign, readonly) BOOL isUIView;

@end

@implementation ZDFlexLayout

@synthesize isEnabled=_isEnabled;
@synthesize isIncludedInLayout=_isIncludedInLayout;
@synthesize node=_node;

+ (void)initialize
{
  globalConfig = YGConfigNew();
  YGConfigSetExperimentalFeatureEnabled(globalConfig, YGExperimentalFeatureWebFlexBasis, true);
  YGConfigSetPointScaleFactor(globalConfig, [UIScreen mainScreen].scale);
}

- (instancetype)initWithView:(ZDFlexLayoutView)view
{
  if (self = [super init]) {
    _view = view;
    _node = YGNodeNewWithConfig(globalConfig);
    YGNodeSetContext(_node, (__bridge void *) view);
    _isEnabled = NO;
    _isIncludedInLayout = YES;
    _isUIView = [view isMemberOfClass:[UIView class]];
  }

  return self;
}

- (void)dealloc
{
  YGNodeFree(self.node);
}

- (BOOL)isDirty
{
  return YGNodeIsDirty(self.node);
}

- (void)markDirty
{
  if (self.isDirty || !self.isLeaf) {
    return;
  }

  // Yoga is not happy if we try to mark a node as "dirty" before we have set
  // the measure function. Since we already know that this is a leaf,
  // this *should* be fine. Forgive me Hack Gods.
  const YGNodeRef node = self.node;
  if (!YGNodeHasMeasureFunc(node)) {
    YGNodeSetMeasureFunc(node, YGMeasureView);
  }

  YGNodeMarkDirty(node);
}

- (NSUInteger)numberOfChildren
{
  return YGNodeGetChildCount(self.node);
}

- (BOOL)isLeaf
{
  NSAssert([NSThread isMainThread], @"This method must be called on the main thread.");
  if (self.isEnabled) {
    for (ZDFlexLayoutView subview in self.view.children) {
      ZDFlexLayout *const yoga = subview.flexLayout;
      if (yoga.isEnabled && yoga.isIncludedInLayout) {
        return NO;
      }
    }
  }

  return YES;
}

#pragma mark - Style

- (YGPositionType)position
{
  return YGNodeStyleGetPositionType(self.node);
}

- (void)setPosition:(YGPositionType)position
{
  YGNodeStyleSetPositionType(self.node, position);
}

YG_PROPERTY(YGDirection, direction, Direction)
YG_PROPERTY(YGFlexDirection, flexDirection, FlexDirection)
YG_PROPERTY(YGJustify, justifyContent, JustifyContent)
YG_PROPERTY(YGAlign, alignContent, AlignContent)
YG_PROPERTY(YGAlign, alignItems, AlignItems)
YG_PROPERTY(YGAlign, alignSelf, AlignSelf)
YG_PROPERTY(YGWrap, flexWrap, FlexWrap)
YG_PROPERTY(YGOverflow, overflow, Overflow)
YG_PROPERTY(YGDisplay, display, Display)

YG_PROPERTY(CGFloat, flex, Flex)
YG_PROPERTY(CGFloat, flexGrow, FlexGrow)
YG_PROPERTY(CGFloat, flexShrink, FlexShrink)
YG_AUTO_VALUE_PROPERTY(flexBasis, FlexBasis)

YG_VALUE_EDGE_PROPERTY(left, Left, Position, YGEdgeLeft)
YG_VALUE_EDGE_PROPERTY(top, Top, Position, YGEdgeTop)
YG_VALUE_EDGE_PROPERTY(right, Right, Position, YGEdgeRight)
YG_VALUE_EDGE_PROPERTY(bottom, Bottom, Position, YGEdgeBottom)
YG_VALUE_EDGE_PROPERTY(start, Start, Position, YGEdgeStart)
YG_VALUE_EDGE_PROPERTY(end, End, Position, YGEdgeEnd)
YG_VALUE_EDGES_PROPERTIES(margin, Margin)
YG_VALUE_EDGES_PROPERTIES(padding, Padding)

YG_EDGE_PROPERTY(borderLeftWidth, BorderLeftWidth, Border, YGEdgeLeft)
YG_EDGE_PROPERTY(borderTopWidth, BorderTopWidth, Border, YGEdgeTop)
YG_EDGE_PROPERTY(borderRightWidth, BorderRightWidth, Border, YGEdgeRight)
YG_EDGE_PROPERTY(borderBottomWidth, BorderBottomWidth, Border, YGEdgeBottom)
YG_EDGE_PROPERTY(borderStartWidth, BorderStartWidth, Border, YGEdgeStart)
YG_EDGE_PROPERTY(borderEndWidth, BorderEndWidth, Border, YGEdgeEnd)
YG_EDGE_PROPERTY(borderWidth, BorderWidth, Border, YGEdgeAll)

YG_AUTO_VALUE_PROPERTY(width, Width)
YG_AUTO_VALUE_PROPERTY(height, Height)
YG_VALUE_PROPERTY(minWidth, MinWidth)
YG_VALUE_PROPERTY(minHeight, MinHeight)
YG_VALUE_PROPERTY(maxWidth, MaxWidth)
YG_VALUE_PROPERTY(maxHeight, MaxHeight)
YG_PROPERTY(CGFloat, aspectRatio, AspectRatio)

#pragma mark - Layout and Sizing

- (YGDirection)resolvedDirection
{
  return YGNodeLayoutGetDirection(self.node);
}

- (void)applyLayout
{
  [self applyLayoutPreservingOrigin:NO];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
{
  [self applyLayoutPreservingOrigin:preserveOrigin constraintSize:self.view.layoutFrame.size];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility
{
  CGSize size = self.view.layoutFrame.size;
  if (dimensionFlexibility & YGDimensionFlexibilityFlexibleWidth) {
    size.width = YGUndefined;
  }
  if (dimensionFlexibility & YGDimensionFlexibilityFlexibleHeight) {
    size.height = YGUndefined;
  }
  [self applyLayoutPreservingOrigin:preserveOrigin constraintSize:size];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin constraintSize:(CGSize)size
{
    if (self.asyncCalculate) {
        [ZDCalculateHelper asyncCalculateTask:^{
            [self calculateLayoutWithSize:size];
        } onComplete:^{
            YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
        }];
    } else {
        [self calculateLayoutWithSize:size];
        YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
    }
}

- (CGSize)intrinsicSize
{
  const CGSize constrainedSize = {
    .width = YGUndefined,
    .height = YGUndefined,
  };
  return [self calculateLayoutWithSize:constrainedSize];
}

- (CGSize)calculateLayoutWithSize:(CGSize)size
{
  //NSAssert([NSThread isMainThread], @"Yoga calculation must be done on main.");
  NSAssert(self.isEnabled, @"Yoga is not enabled for this view.");

  YG_Dispatch_sync_on_main_queue(^{
    YGAttachNodesFromViewHierachy(self.view);
  });

  const YGNodeRef node = self.node;
  YGNodeCalculateLayout(
    node,
    size.width,
    size.height,
    YGNodeStyleGetDirection(node));

  return (CGSize) {
    .width = YGNodeLayoutGetWidth(node),
    .height = YGNodeLayoutGetHeight(node),
  };
}

#pragma mark - Private

static YGSize YGMeasureView(
  YGNodeRef node,
  float width,
  YGMeasureMode widthMode,
  float height,
  YGMeasureMode heightMode)
{
  const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
  const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX: height;

  __block CGSize sizeThatFits = CGSizeZero;

  // The default implementation of sizeThatFits: returns the existing size of
  // the view. That means that if we want to layout an empty UIView, which
  // already has got a frame set, its measured size should be CGSizeZero, but
  // UIKit returns the existing size.
  //
  // See https://github.com/facebook/yoga/issues/606 for more information.
  YG_Dispatch_sync_on_main_queue(^{
    ZDFlexLayoutView view = (__bridge ZDFlexLayoutView) YGNodeGetContext(node);
    if (!view.flexLayout.isUIView || [view.children count] > 0) {
        sizeThatFits = [view sizeThatFits:(CGSize){
                                                .width = constrainedWidth,
                                                .height = constrainedHeight,
                                            }];
    }
  });

  return (YGSize) {
    .width = YGSanitizeMeasurement(constrainedWidth, sizeThatFits.width, widthMode),
    .height = YGSanitizeMeasurement(constrainedHeight, sizeThatFits.height, heightMode),
  };
}

static CGFloat YGSanitizeMeasurement(
  CGFloat constrainedSize,
  CGFloat measuredSize,
  YGMeasureMode measureMode)
{
  CGFloat result;
  if (measureMode == YGMeasureModeExactly) {
    result = constrainedSize;
  } else if (measureMode == YGMeasureModeAtMost) {
    result = MIN(constrainedSize, measuredSize);
  } else {
    result = measuredSize;
  }

  return result;
}

static BOOL YGNodeHasExactSameChildren(const YGNodeRef node, NSArray<ZDFlexLayoutView> *subviews)
{
  if (YGNodeGetChildCount(node) != subviews.count) {
    return NO;
  }

  for (int i=0; i<subviews.count; i++) {
    if (YGNodeGetChild(node, i) != subviews[i].flexLayout.node) {
      return NO;
    }
  }

  return YES;
}

static void YGAttachNodesFromViewHierachy(ZDFlexLayoutView const view)
{
  ZDFlexLayout *const yoga = view.flexLayout;
  const YGNodeRef node = yoga.node;

  // Only leaf nodes should have a measure function
  if (yoga.isLeaf) {
    YGRemoveAllChildren(node);
    YGNodeSetMeasureFunc(node, YGMeasureView);
  } else {
    YGNodeSetMeasureFunc(node, NULL);

    NSMutableArray<ZDFlexLayoutView> *subviewsToInclude = [[NSMutableArray alloc] initWithCapacity:view.children.count];
    for (ZDFlexLayoutView subview in view.children) {
      if (subview.flexLayout.isEnabled && subview.flexLayout.isIncludedInLayout) {
        [subviewsToInclude addObject:subview];
      }
    }

    if (!YGNodeHasExactSameChildren(node, subviewsToInclude)) {
      YGRemoveAllChildren(node);
      for (int i=0; i<subviewsToInclude.count; i++) {
        YGNodeInsertChild(node, subviewsToInclude[i].flexLayout.node, i);
      }
    }

    for (ZDFlexLayoutView const subview in subviewsToInclude) {
      YGAttachNodesFromViewHierachy(subview);
    }
  }
}

static void YGRemoveAllChildren(const YGNodeRef node)
{
  if (node == NULL) {
    return;
  }

  YGNodeRemoveAllChildren(node);
}

static CGFloat YGRoundPixelValue(CGFloat value)
{
  static CGFloat scale;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^(){
    scale = [UIScreen mainScreen].scale;
  });

  return roundf(value * scale) / scale;
}

static void YGApplyLayoutToViewHierarchy(ZDFlexLayoutView view, BOOL preserveOrigin)
{
  NSCAssert([NSThread isMainThread], @"Framesetting should only be done on the main thread.");

  const ZDFlexLayout *yoga = view.flexLayout;

  if (!yoga.isIncludedInLayout) {
     return;
  }

  YGNodeRef node = yoga.node;
  const CGPoint topLeft = {
    YGNodeLayoutGetLeft(node),
    YGNodeLayoutGetTop(node),
  };

  const CGPoint bottomRight = {
    topLeft.x + YGNodeLayoutGetWidth(node),
    topLeft.y + YGNodeLayoutGetHeight(node),
  };

  const CGPoint origin = preserveOrigin ? view.layoutFrame.origin : CGPointZero;
  view.layoutFrame = (CGRect) {
    .origin = {
      .x = YGRoundPixelValue(topLeft.x + origin.x),
      .y = YGRoundPixelValue(topLeft.y + origin.y),
    },
    .size = {
      .width = YGRoundPixelValue(bottomRight.x) - YGRoundPixelValue(topLeft.x),
      .height = YGRoundPixelValue(bottomRight.y) - YGRoundPixelValue(topLeft.y),
    },
  };

  if (!yoga.isLeaf) {
    for (NSUInteger i = 0; i < view.children.count; i++) {
      YGApplyLayoutToViewHierarchy(view.children[i], NO);
    }
      
    // TODO:
    if ([view isKindOfClass:UIScrollView.class] && objc_getAssociatedObject(view, @selector(zd_contentView))) {
          UIScrollView *scrollView = (UIScrollView *)view;
          scrollView.contentSize = scrollView.zd_contentView.layoutFrame.size;
          
          CGFloat owningViewWidth = CGRectGetWidth(view.owningView.frame);
          CGFloat owningViewHeight = CGRectGetHeight(view.owningView.frame);
          
          CGRect tmpFrame = scrollView.frame;
          CGFloat scrollViewWidth = CGRectGetWidth(tmpFrame);
          CGFloat scrollViewHeight = CGRectGetHeight(tmpFrame);
          
          if (scrollViewWidth > owningViewWidth) {
              tmpFrame.size.width = owningViewWidth;
          }
          if (scrollViewHeight > owningViewHeight) {
              tmpFrame.size.height = owningViewHeight;
          }
          view.layoutFrame = tmpFrame;
    }
  }
}

/*
static void YGAddViewFromDivHierachy(ZDFlexLayoutView view)
{
    NSCAssert([NSThread isMainThread], @"addSubview: should only be done on the main thread.");
    
    if (view == nil) {
        return;
    }
    
    const ZDFlexLayout *yoga = view.flexLayout;
    
    if (yoga.isLeaf) {
       return;
    }
    
    // add self.view to superview if self.view.superview is nil
    UIView *subParentView = nil;
    if ([view isKindOfClass:UIView.class]) {
        subParentView = (UIView *)view;
        
        if ( !((UIView *)view).superview ) {
            [view.owningView addSubview:(UIView *)view];
        }
    }
    else {
        subParentView = view.owningView;
        NSCAssert(subParentView, @"owningView should't be nil");
    }
    
    for (ZDFlexLayoutView childView in view.children) {
        if ([childView isKindOfClass:UIView.class]) {
            UIView *subView = (UIView *)childView;
            [subView removeFromSuperview];
            [subParentView addSubview:subView];
        }
        
        // recursive addSubview
        //YGAddViewFromDivHierachy(childView);
    }
}
*/

static void YG_Dispatch_sync_on_main_queue(dispatch_block_t block) {
    if (NSThread.isMainThread) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
