/*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/

#import "ZDFlexLayoutCore+Private.h"
#import <objc/runtime.h>
#import "ZDCalculateHelper.h"

#define YG_PROPERTY(type, lowercased_name, capitalized_name)            \
    - (type)lowercased_name                                             \
    {                                                                   \
        return YGNodeStyleGet ## capitalized_name(self.node);           \
    }                                                                   \
                                                                        \
    - (void)set ## capitalized_name: (type)lowercased_name              \
    {                                                                   \
        YGNodeStyleSet ## capitalized_name(self.node, lowercased_name); \
    }

#define YG_VALUE_PROPERTY(lowercased_name, capitalized_name)                                        \
    - (YGValue)lowercased_name                                                                      \
    {                                                                                               \
        return YGNodeStyleGet ## capitalized_name(self.node);                                       \
    }                                                                                               \
                                                                                                    \
    - (void)set ## capitalized_name: (YGValue)lowercased_name                                       \
    {                                                                                               \
        switch (lowercased_name.unit) {                                                             \
            case YGUnitUndefined:                                                                   \
                YGNodeStyleSet ## capitalized_name(self.node, lowercased_name.value);               \
                break;                                                                              \
            case YGUnitPoint:                                                                       \
                YGNodeStyleSet ## capitalized_name(self.node, lowercased_name.value);               \
                break;                                                                              \
            case YGUnitPercent:                                                                     \
                YGNodeStyleSet ## capitalized_name ## Percent(self.node, lowercased_name.value);    \
                break;                                                                              \
            default:                                                                                \
                NSAssert(NO, @"Not implemented");                                                   \
        }                                                                                           \
    }

#define YG_AUTO_VALUE_PROPERTY(lowercased_name, capitalized_name)                                   \
    - (YGValue)lowercased_name                                                                      \
    {                                                                                               \
        return YGNodeStyleGet ## capitalized_name(self.node);                                       \
    }                                                                                               \
                                                                                                    \
    - (void)set ## capitalized_name: (YGValue)lowercased_name                                       \
    {                                                                                               \
        switch (lowercased_name.unit) {                                                             \
            case YGUnitPoint:                                                                       \
                YGNodeStyleSet ## capitalized_name(self.node, lowercased_name.value);               \
                break;                                                                              \
            case YGUnitPercent:                                                                     \
                YGNodeStyleSet ## capitalized_name ## Percent(self.node, lowercased_name.value);    \
                break;                                                                              \
            case YGUnitAuto:                                                                        \
                YGNodeStyleSet ## capitalized_name ## Auto(self.node);                              \
                break;                                                                              \
            default:                                                                                \
                NSAssert(NO, @"Not implemented");                                                   \
        }                                                                                           \
    }

#define YG_EDGE_PROPERTY_GETTER(type, lowercased_name, capitalized_name, property, edge)            \
    - (type)lowercased_name                                                                         \
    {                                                                                               \
        return YGNodeStyleGet ## property(self.node, edge);                                         \
    }

#define YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)                  \
    - (void)set ## capitalized_name: (CGFloat)lowercased_name                                       \
    {                                                                                               \
        YGNodeStyleSet ## property(self.node, edge, lowercased_name);                               \
    }

#define YG_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge)                         \
    YG_EDGE_PROPERTY_GETTER(CGFloat, lowercased_name, capitalized_name, property, edge)             \
    YG_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGE_PROPERTY_SETTER(objc_lowercased_name, objc_capitalized_name, c_name, edge)    \
    - (void)set ## objc_capitalized_name: (YGValue)objc_lowercased_name                             \
    {                                                                                               \
        switch (objc_lowercased_name.unit) {                                                        \
            case YGUnitUndefined:                                                                   \
                YGNodeStyleSet ## c_name(self.node, edge, objc_lowercased_name.value);              \
                break;                                                                              \
            case YGUnitPoint:                                                                       \
                YGNodeStyleSet ## c_name(self.node, edge, objc_lowercased_name.value);              \
                break;                                                                              \
            case YGUnitPercent:                                                                     \
                YGNodeStyleSet ## c_name ## Percent(self.node, edge, objc_lowercased_name.value);   \
                break;                                                                              \
            default:                                                                                \
                NSAssert(NO, @"Not implemented");                                                   \
        }                                                                                           \
    }

#define YG_VALUE_EDGE_PROPERTY(lowercased_name, capitalized_name, property, edge)       \
    YG_EDGE_PROPERTY_GETTER(YGValue, lowercased_name, capitalized_name, property, edge) \
    YG_VALUE_EDGE_PROPERTY_SETTER(lowercased_name, capitalized_name, property, edge)

#define YG_VALUE_EDGES_PROPERTIES(lowercased_name, capitalized_name)                                                          \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Left, capitalized_name ## Left, capitalized_name, YGEdgeLeft)                   \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Top, capitalized_name ## Top, capitalized_name, YGEdgeTop)                      \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Right, capitalized_name ## Right, capitalized_name, YGEdgeRight)                \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Bottom, capitalized_name ## Bottom, capitalized_name, YGEdgeBottom)             \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Start, capitalized_name ## Start, capitalized_name, YGEdgeStart)                \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## End, capitalized_name ## End, capitalized_name, YGEdgeEnd)                      \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Horizontal, capitalized_name ## Horizontal, capitalized_name, YGEdgeHorizontal) \
    YG_VALUE_EDGE_PROPERTY(lowercased_name ## Vertical, capitalized_name ## Vertical, capitalized_name, YGEdgeVertical)       \
    YG_VALUE_EDGE_PROPERTY(lowercased_name, capitalized_name, capitalized_name, YGEdgeAll)

__attribute__((weak)) YGValue YGPointValue(CGFloat value)
{
    return (YGValue) { .value = value, .unit = YGUnitPoint };
}

__attribute__((weak)) YGValue YGPercentValue(CGFloat value)
{
    return (YGValue) { .value = value, .unit = YGUnitPercent };
}

static YGConfigRef globalConfig;

@interface ZDFlexLayoutCore ()

@property (nonatomic, weak, readwrite) ZDFlexLayoutView view;
@property (nonatomic, assign, readonly) BOOL isUIView;

@end

@implementation ZDFlexLayoutCore

@synthesize isEnabled = _isEnabled;
@synthesize isIncludedInLayout = _isIncludedInLayout;
@synthesize node = _node;

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
        YGNodeSetContext(_node, (__bridge void *)view);
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
            ZDFlexLayoutCore *const yoga = subview.flexLayout;
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

#pragma mark - Sync

- (void)applyLayout
{
    [self applyLayoutPreservingOrigin:NO];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin
{
    [self asyncApplyLayout:NO preservingOrigin:preserveOrigin constraintSize:self.view.layoutFrame.size];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility
{
    [self asyncApplyLayout:NO preservingOrigin:preserveOrigin dimensionFlexibility:dimensionFlexibility];
}

#pragma mark - Async

- (void)asyncApplyLayoutPreservingOrigin:(BOOL)preserveOrigin
{
    [self asyncApplyLayout:YES preservingOrigin:preserveOrigin constraintSize:self.view.layoutFrame.size];
}

- (void)asyncApplyLayout:(BOOL)async preservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility
{
    CGSize size = self.view.layoutFrame.size;
    if (dimensionFlexibility & ZDDimensionFlexibilityFlexibleWidth) {
        size.width = YGUndefined;
    }
    if (dimensionFlexibility & ZDDimensionFlexibilityFlexibleHeight) {
        size.height = YGUndefined;
    }
    [self asyncApplyLayout:async preservingOrigin:preserveOrigin constraintSize:size];
}

- (void)asyncApplyLayout:(BOOL)async preservingOrigin:(BOOL)preserveOrigin constraintSize:(CGSize)size
{
    self.isEnabled = YES;
    if (async) {
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

#pragma mark -

- (CGSize)intrinsicSize
{
    const CGSize constrainedSize = {
        .width  = YGUndefined,
        .height = YGUndefined,
    };
    return [self calculateLayoutWithSize:constrainedSize];
}

- (CGSize)calculateLayoutWithSize:(CGSize)size
{
    //NSAssert([NSThread isMainThread], @"Yoga calculation must be done on main.");
    NSAssert(self.isEnabled, @"Yoga is not enabled for this view.");

    ZD_Dispatch_sync_on_main_queue(^{
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
    const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : height;

    __block CGSize sizeThatFits = CGSizeZero;

    // The default implementation of sizeThatFits: returns the existing size of
    // the view. That means that if we want to layout an empty UIView, which
    // already has got a frame set, its measured size should be CGSizeZero, but
    // UIKit returns the existing size.
    //
    // See https://github.com/facebook/yoga/issues/606 for more information.
    ZD_Dispatch_sync_on_main_queue(^{
        ZDFlexLayoutView view = (__bridge ZDFlexLayoutView)YGNodeGetContext(node);
        if (!view.flexLayout.isUIView || [view.children count] > 0) {
            sizeThatFits = [view sizeThatFits:(CGSize) {
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

    for (int i = 0; i < subviews.count; i++) {
        if (YGNodeGetChild(node, i) != subviews[i].flexLayout.node) {
            return NO;
        }
    }

    return YES;
}

static void YGAttachNodesFromViewHierachy(ZDFlexLayoutView const view)
{
    ZDFlexLayoutCore *const yoga = view.flexLayout;
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
            for (int i = 0; i < subviewsToInclude.count; i++) {
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

static void YGApplyLayoutToViewHierarchy(ZDFlexLayoutView view, BOOL preserveOrigin)
{
    NSCAssert([NSThread isMainThread], @"Framesetting should only be done on the main thread.");

    const ZDFlexLayoutCore *yoga = view.flexLayout;

    if (!yoga.isEnabled || !yoga.isIncludedInLayout) {
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
            .x = ZDFLRoundPixelValue(topLeft.x + origin.x),
            .y = ZDFLRoundPixelValue(topLeft.y + origin.y),
        },
        .size = {
            .width  = ZDFLRoundPixelValue(bottomRight.x) - ZDFLRoundPixelValue(topLeft.x),
            .height = ZDFLRoundPixelValue(bottomRight.y) - ZDFLRoundPixelValue(topLeft.y),
        },
    };

    if (!yoga.isLeaf) {
        for (NSUInteger i = 0; i < view.children.count; i++) {
            YGApplyLayoutToViewHierarchy(view.children[i], NO);
        }

        if ([view respondsToSelector:@selector(needReApplyLayoutAtNextRunloop)]) {
            [view needReApplyLayoutAtNextRunloop];
        }
    }
}

static void ZD_Dispatch_sync_on_main_queue(dispatch_block_t block)
{
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end

//-------------------------- Function ------------------------
#pragma mark -

CGFloat ZDFLScreenScale(void)
{
    static CGFloat scale = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), YES, 0);
        scale = CGContextGetCTM(UIGraphicsGetCurrentContext()).a;
        UIGraphicsEndImageContext();
    });
    return scale;
}

CGFloat ZDFLRoundPixelValue(CGFloat value)
{
    CGFloat scale = ZDFLScreenScale();
    return roundf(value * scale) / scale;
}

CGFloat ZDFLCeilPixelValue(CGFloat value)
{
    CGFloat scale = ZDFLScreenScale();
    return ceil((value - FLT_EPSILON) * scale) / scale;
}

CGFloat ZDFLFloorPixelValue(CGFloat f)
{
    CGFloat scale = ZDFLScreenScale();
    return floor((f + FLT_EPSILON) * scale) / scale;
}
