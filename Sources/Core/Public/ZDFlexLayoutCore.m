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

__attribute__((weak)) YGValue YGPointValue(CGFloat value) {
    return (YGValue) { .value = value, .unit = YGUnitPoint };
}

__attribute__((weak)) YGValue YGPercentValue(CGFloat value) {
	return (YGValue) { .value = value, .unit = YGUnitPercent };
}

static YGConfigRef globalConfig;

@interface ZDFlexLayoutCore ()

@property (nonatomic, weak, readwrite) ZDFlexLayoutView view;
@property (nonatomic, assign, readonly) BOOL isUIView;

/// Per-pass measure cache, safe for concurrent async layouts of different roots.
@property (nonatomic, strong) NSMutableDictionary *asyncMeasureCache;

@end

@implementation ZDFlexLayoutCore

@synthesize isEnabled = _isEnabled;
@synthesize isIncludedInLayout = _isIncludedInLayout;
@synthesize node = _node;

+ (void)initialize {
	globalConfig = YGConfigNew();
	YGConfigSetExperimentalFeatureEnabled(globalConfig, YGExperimentalFeatureWebFlexBasis, true);
	YGConfigSetPointScaleFactor(globalConfig, [UIScreen mainScreen].scale);
}

- (instancetype)initWithView:(ZDFlexLayoutView)view {
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

- (void)dealloc {
	YGNodeFree(self.node);
}

- (BOOL)isDirty {
	return YGNodeIsDirty(self.node);
}

- (void)markDirty {
	
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

- (NSUInteger)numberOfChildren {
	return YGNodeGetChildCount(self.node);
}

- (BOOL)isLeaf {
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

- (YGPositionType)position {
	return YGNodeStyleGetPositionType(self.node);
}

- (void)setPosition:(YGPositionType)position {
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
YG_PROPERTY(YGBoxSizing, boxSizing, BoxSizing)

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

YG_VALUE_EDGE_PROPERTY(rowGap, RowGap, Gap, YGGutterRow)
YG_VALUE_EDGE_PROPERTY(columnGap, ColumnGap, Gap, YGGutterColumn)
YG_VALUE_EDGE_PROPERTY(allGap, AllGap, Gap, YGGutterAll)

#pragma mark - Layout and Sizing

- (YGDirection)resolvedDirection {
	
	return YGNodeLayoutGetDirection(self.node);
}

#pragma mark - Sync

- (void)applyLayout {
	
	[self applyLayoutPreservingOrigin:NO];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin {
	
	[self asyncApplyLayout:NO preservingOrigin:preserveOrigin constraintSize:self.view.layoutFrame.size];
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility {
	
	[self asyncApplyLayout:NO preservingOrigin:preserveOrigin dimensionFlexibility:dimensionFlexibility];
}

#pragma mark - Async

- (void)asyncApplyLayoutPreservingOrigin:(BOOL)preserveOrigin {
	
	[self asyncApplyLayout:YES preservingOrigin:preserveOrigin constraintSize:self.view.layoutFrame.size];
}

- (void)asyncApplyLayout:(BOOL)async preservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility {
	
	CGSize size = self.view.layoutFrame.size;
	if (dimensionFlexibility & ZDDimensionFlexibilityFlexibleWidth) {
		size.width = YGUndefined;
	}
	if (dimensionFlexibility & ZDDimensionFlexibilityFlexibleHeight) {
		size.height = YGUndefined;
	}
	[self asyncApplyLayout:async preservingOrigin:preserveOrigin constraintSize:size];
}

- (void)asyncApplyLayout:(BOOL)async preservingOrigin:(BOOL)preserveOrigin constraintSize:(CGSize)size {
	
	ZDFlexLayoutAsyncMode asyncMode = async ? ZDFlexLayoutAsyncModeRunloopIdle : ZDFlexLayoutAsyncModeSync;
	[self applyLayoutWithAsyncMode:asyncMode preservingOrigin:preserveOrigin constraintSize:size];
}

#pragma mark - Async Mode API

- (void)applyLayoutWithAsyncMode:(ZDFlexLayoutAsyncMode)asyncMode
				preservingOrigin:(BOOL)preserveOrigin
			dimensionFlexibility:(ZDDimensionFlexibility)dimensionFlexibility {
	
	CGSize size = self.view.layoutFrame.size;
	if (dimensionFlexibility & ZDDimensionFlexibilityFlexibleWidth) {
		size.width = YGUndefined;
	}
	if (dimensionFlexibility & ZDDimensionFlexibilityFlexibleHeight) {
		size.height = YGUndefined;
	}
	[self applyLayoutWithAsyncMode:asyncMode preservingOrigin:preserveOrigin constraintSize:size];
}

- (void)applyLayoutWithAsyncMode:(ZDFlexLayoutAsyncMode)asyncMode
				preservingOrigin:(BOOL)preserveOrigin
				  constraintSize:(CGSize)size {
	
	self.isEnabled = YES;
	
	switch (asyncMode) {
		case ZDFlexLayoutAsyncModeBackgroundThread: {
			[self updateLayoutDirectionIfNeeded];
			
			__weak typeof(self) weakTarget = self;
			
			if (self.useLegacyPreMeasure) {
				// Legacy path: pre-measure by mutating YGNode style directly
				YGAttachNodesFromViewHierachy(self.view, YES);
				
				[ZDCalculateHelper asyncCalculateTask:^{
					__strong typeof(weakTarget) self = weakTarget;
					if (!self) return;
					const YGNodeRef node = self.node;
					YGNodeCalculateLayout(node, size.width, size.height, YGNodeStyleGetDirection(node));
				} onComplete:^{
					__strong typeof(weakTarget) self = weakTarget;
					if (!self) return;
					YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
				}];
			} else {
				// Phase 1 (main thread): pre-measure all leaves, store in per-pass cache
				self.asyncMeasureCache = [NSMutableDictionary dictionary];
				YGPreMeasureAndCacheLeafNodes(self.view, self.asyncMeasureCache);
				
				// Phase 2 (background thread): pure numeric Yoga calculation
				[ZDCalculateHelper asyncCalculateTask:^{
					__strong typeof(weakTarget) self = weakTarget;
					if (!self) return;
					const YGNodeRef node = self.node;
					YGNodeCalculateLayout(node, size.width, size.height, YGNodeStyleGetDirection(node));
				} onComplete:^{
					// Phase 3 (main thread): apply frames, restore measure funcs, clear cache
					__strong typeof(weakTarget) self = weakTarget;
					if (!self) return;
					YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
					YGRestoreMeasureFuncs(self.view);
					self.asyncMeasureCache = nil;
				}];
			}
			break;
		}
		case ZDFlexLayoutAsyncModeRunloopIdle: {
			__weak typeof(self) weakTarget = self;
			__auto_type calculateBlock = ^{
				__strong typeof(weakTarget) self = weakTarget;
				if (!self) return;
				[self calculateLayoutWithSize:size];
				YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
			};
			[ZDCalculateHelper asyncLayoutTask:calculateBlock];
			break;
		}
		case ZDFlexLayoutAsyncModeSync:
		default: {
			[self calculateLayoutWithSize:size];
			YGApplyLayoutToViewHierarchy(self.view, preserveOrigin);
			break;
		}
	}
}

#pragma mark -

- (CGSize)intrinsicSize {
	const CGSize constrainedSize = {
		.width  = YGUndefined,
		.height = YGUndefined,
	};
	return [self calculateLayoutWithSize:constrainedSize];
}

- (void)updateLayoutDirectionIfNeeded {
	// Must be called on main thread — accesses UIView.traitCollection
	UIView *view = self.view.owningView;
	if (view && view.traitCollection.layoutDirection != UITraitEnvironmentLayoutDirectionUnspecified) {
		self.direction = view.traitCollection.layoutDirection == UITraitEnvironmentLayoutDirectionLeftToRight ? YGDirectionRTL : YGDirectionLTR;
	}
}

- (CGSize)calculateLayoutWithSize:(CGSize)size {
	return [self calculateLayoutWithSize:size asyncMode:NO];
}

- (CGSize)calculateLayoutWithSize:(CGSize)size asyncMode:(BOOL)asyncMode {
	NSAssert(self.isEnabled, @"Yoga is not enabled for this view.");
	
	YGAttachNodesFromViewHierachy(self.view, asyncMode);
	
	const YGNodeRef node = self.node;
	YGNodeCalculateLayout(
						  node,
						  size.width,
						  size.height,
						  YGNodeStyleGetDirection(node)
						  );
	
	return (CGSize) {
		.width = YGNodeLayoutGetWidth(node),
		.height = YGNodeLayoutGetHeight(node),
	};
}

#pragma mark - Measure Cache Per-Pass
// Each async layout pass gets its own cache on the root ZDFlexLayoutCore.
// This eliminates race conditions between concurrent async layouts of different roots.
// key: NSValue(pointer:YGNodeRef), value: NSValue(CGSize) or text-storage-dictionary

static NSValue *ZDNodeKey(YGNodeConstRef node) {
    return [NSValue valueWithPointer:node];
}

static void ZDMeasureCacheSetSize(NSMutableDictionary *cache, YGNodeRef node, CGSize size) {
    if (!cache) return;
    cache[ZDNodeKey(node)] = [NSValue valueWithCGSize:size];
}

static void ZDMeasureCacheSetTextStorage(NSMutableDictionary *cache, YGNodeRef node, NSTextStorage *textStorage, NSInteger numberOfLines) {
    if (!cache || !textStorage) return;
    cache[ZDNodeKey(node)] = @{@"storage": textStorage, @"lines": @(numberOfLines)};
}

/// Finds the async measure cache by walking up the view tree to the root, then
/// reading root.flexLayout.asyncMeasureCache. Thread-safe since the cache
/// is written once on main thread before dispatching to background.
static NSMutableDictionary *ZDGetCurrentAsyncCache(YGNodeConstRef node) {
    ZDFlexLayoutView view = (__bridge ZDFlexLayoutView)YGNodeGetContext(node);
    if (!view) return nil;
    while (view.parent) { view = view.parent; }
    return view.flexLayout.asyncMeasureCache;
}

/// 使用 TextKit 测量文本（线程安全），借鉴 React Native 的实现方式。
/// 支持 NSTextStorage 直接传入（后台线程），或从 UILabel 提取文本信息（主线程）。
static CGSize ZDMeasureText(NSTextStorage *textStorage, NSInteger numberOfLines, CGSize constraintSize) {
    if (!textStorage || textStorage.length == 0) return CGSizeZero;

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:constraintSize];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = numberOfLines;
    textContainer.lineBreakMode = NSLineBreakByWordWrapping;

    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager ensureLayoutForTextContainer:textContainer];

    CGRect usedRect = [layoutManager usedRectForTextContainer:textContainer];
    [textStorage removeLayoutManager:layoutManager];

    return CGSizeMake(ceil(usedRect.size.width), ceil(usedRect.size.height));
}

/// 从 UILabel 构造 NSTextStorage（主线程调用，捕获文本快照）
static NSTextStorage *ZDTextStorageFromLabel(UILabel *label) {
    NSAttributedString *attrText = label.attributedText;
    if (attrText.length > 0) {
        return [[NSTextStorage alloc] initWithAttributedString:attrText];
    }
    if (label.text.length > 0) {
        NSDictionary *attrs = label.font ? @{NSFontAttributeName: label.font} : @{};
        return [[NSTextStorage alloc] initWithString:label.text attributes:attrs];
    }
    return nil;
}

#pragma mark - Private

// Pre-measure a leaf node and set its size as fixed width/height on the Yoga node.
// This allows us to skip setting YGMeasureFunc and run Yoga calculation on a background thread.
// Returns YES if the node was fully pre-measured (no measure func needed).
static BOOL YGPreMeasureLeafNode(YGNodeRef node, ZDFlexLayoutView view) {
	
	YGValue nodeWidth = YGNodeStyleGetWidth(node);
	YGValue nodeHeight = YGNodeStyleGetHeight(node);
	
	BOOL hasExplicitWidth = (nodeWidth.unit == YGUnitPoint && !YGFloatIsUndefined(nodeWidth.value));
	BOOL hasExplicitHeight = (nodeHeight.unit == YGUnitPoint && !YGFloatIsUndefined(nodeHeight.value));
	
	if (hasExplicitWidth && hasExplicitHeight) {
		return YES; // Already fully constrained, no measure func needed
	}
	
	if (!view.flexLayout.isUIView) {
		// ZDFlexLayoutDiv — sizeThatFits returns CGSizeZero, thread-safe
		// Keep the measure function for these; they don't call UIKit
		return NO;
	}
	
	UIView *uiView = (UIView *)view;
	CGSize measuredSize = CGSizeZero;
	
	if ([uiView isKindOfClass:[UILabel class]]) {
		UILabel *label = (UILabel *)uiView;
		CGSize constrainedSize = (CGSize){
			hasExplicitWidth ? nodeWidth.value : CGFLOAT_MAX,
			hasExplicitHeight ? nodeHeight.value : CGFLOAT_MAX
		};
		NSTextStorage *ts = ZDTextStorageFromLabel(label);
		measuredSize = ZDMeasureText(ts, label.numberOfLines, constrainedSize);
	} else if ([uiView isKindOfClass:[UIImageView class]]) {
		UIImage *image = ((UIImageView *)uiView).image;
		if (image) {
			measuredSize = image.size;
		}
	} else {
		// For other UIView leaf nodes (plain UIView, custom views, etc.):
		// sizeThatFits: requires main thread.
		// If neither width nor height is set, we must call sizeThatFits: on main thread.
		// If at least one dimension is set, we can skip measurement.
		if (!hasExplicitWidth && !hasExplicitHeight) {
			// Must measure on main thread — keep measure func
			return NO;
		}
		// At least one dimension is explicit — store what we have
		measuredSize = CGSizeMake(
								  hasExplicitWidth ? nodeWidth.value : CGFLOAT_MAX,
								  hasExplicitHeight ? nodeHeight.value : CGFLOAT_MAX
								  );
	}
	
	if (!hasExplicitWidth && measuredSize.width > 0 && measuredSize.width < CGFLOAT_MAX) {
		YGNodeStyleSetWidth(node, measuredSize.width);
	}
	if (!hasExplicitHeight && measuredSize.height > 0 && measuredSize.height < CGFLOAT_MAX) {
		YGNodeStyleSetHeight(node, measuredSize.height);
	}
	
	return YES;
}

static YGSize YGMeasureView(
	YGNodeConstRef node,
	float width,
	YGMeasureMode widthMode,
	float height,
	YGMeasureMode heightMode
) {
	const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
	const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : height;
	
	CGSize sizeThatFits = CGSizeZero;
	
	// The default implementation of sizeThatFits: returns the existing size of
	// the view. That means that if we want to layout an empty UIView, which
	// already has got a frame set, its measured size should be CGSizeZero, but
	// UIKit returns the existing size.
	//
	// See https://github.com/facebook/yoga/issues/606 for more information.
	ZDFlexLayoutView view = (__bridge ZDFlexLayoutView)YGNodeGetContext(node);
	if (!view.flexLayout.isUIView || [view.children count] > 0) {
		sizeThatFits = [view sizeThatFits:(CGSize) {
			.width = constrainedWidth,
			.height = constrainedHeight,
		}];
	}
	
	return (YGSize) {
		.width = YGSanitizeMeasurement(constrainedWidth, sizeThatFits.width, widthMode),
		.height = YGSanitizeMeasurement(constrainedHeight, sizeThatFits.height, heightMode),
	};
}

static CGFloat YGSanitizeMeasurement(
	CGFloat constrainedSize,
	CGFloat measuredSize,
	YGMeasureMode measureMode
) {
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

/// 后台线程安全的 measure 函数。
/// 文本节点使用 TextKit 在 Yoga 提供的真实约束下测量；非文本节点返回预存的固定尺寸。
/// 通过节点上下文找到当前布局的根视图，从根视图的 per-pass cache 读取数据，
/// 避免多次并发异步布局之间的竞态条件。
static YGSize YGCachedMeasureView(
    YGNodeConstRef node,
    float width,
    YGMeasureMode widthMode,
    float height,
    YGMeasureMode heightMode
) {
    const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
    const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : height;

    NSMutableDictionary *cache = ZDGetCurrentAsyncCache(node);
    if (!cache) return (YGSize){ .width = 0, .height = 0 };

    id cached = cache[ZDNodeKey(node)];
    if (!cached) return (YGSize){ .width = 0, .height = 0 };

    CGSize measuredSize;
    if ([cached isKindOfClass:[NSDictionary class]]) {
        NSTextStorage *textStorage = cached[@"storage"];
        NSInteger numberOfLines = [cached[@"lines"] integerValue];
        CGSize constraint = CGSizeMake(constrainedWidth, constrainedHeight);
        measuredSize = ZDMeasureText(textStorage, numberOfLines, constraint);
    } else {
        measuredSize = [(NSValue *)cached CGSizeValue];
    }

    return (YGSize) {
        .width = YGSanitizeMeasurement(constrainedWidth, measuredSize.width, widthMode),
        .height = YGSanitizeMeasurement(constrainedHeight, measuredSize.height, heightMode),
    };
}

static void YGPreMeasureAndCacheLeafNodes(ZDFlexLayoutView const view, NSMutableDictionary *cache);

static BOOL YGNodeHasExactSameChildren(const YGNodeRef node, NSArray<ZDFlexLayoutView> *subviews) {
	
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

static void YGAttachNodesFromViewHierachy(ZDFlexLayoutView const view, BOOL asyncMode) {
	
	ZDFlexLayoutCore *const yoga = view.flexLayout;
	const YGNodeRef node = yoga.node;
	
	// Only leaf nodes should have a measure function
	if (yoga.isLeaf) {
		YGRemoveAllChildren(node);
		
		if (asyncMode) {
			// In async mode, try to pre-measure the leaf node and set fixed sizes.
			// If fully pre-measured, skip setting YGMeasureFunc so Yoga won't
			// call back into UIKit during background calculation.
			if (YGPreMeasureLeafNode(node, view)) {
				YGNodeSetMeasureFunc(node, NULL);
			} else if (!yoga.isUIView) {
				// Non-UIView (ZDFlexLayoutDiv): sizeThatFits returns CGSizeZero, thread-safe
				YGNodeSetMeasureFunc(node, YGMeasureView);
			} else {
				// UIView leaf that couldn't be pre-measured (no explicit size, not UILabel/UIImageView).
				// Setting YGMeasureFunc would call sizeThatFits: on background thread → unsafe.
				// Instead, leave measure func unset and let Yoga use default sizing.
				YGNodeSetMeasureFunc(node, NULL);
			}
		} else {
			YGNodeSetMeasureFunc(node, YGMeasureView);
		}
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
			YGAttachNodesFromViewHierachy(subview, asyncMode);
		}
	}
}

/// 主线程递归遍历视图树，预测量所有叶子节点的固有尺寸并存入缓存侧表。
/// 每个叶子节点设置 YGCachedMeasureView 作为 measure 函数，确保后台计算时不回调 UIKit。
/// 不修改 YGNode 的 style 属性（width/height），避免污染后续布局。
static void YGPreMeasureAndCacheLeafNodes(ZDFlexLayoutView const view, NSMutableDictionary *cache) {
	
	ZDFlexLayoutCore *const yoga = view.flexLayout;
	const YGNodeRef node = yoga.node;

	if (yoga.isLeaf) {
		YGRemoveAllChildren(node);

		YGValue nodeWidth = YGNodeStyleGetWidth(node);
		YGValue nodeHeight = YGNodeStyleGetHeight(node);
		BOOL hasExplicitWidth = (nodeWidth.unit == YGUnitPoint && !YGFloatIsUndefined(nodeWidth.value));
		BOOL hasExplicitHeight = (nodeHeight.unit == YGUnitPoint && !YGFloatIsUndefined(nodeHeight.value));
		
		if (hasExplicitWidth && hasExplicitHeight) {
			YGNodeSetMeasureFunc(node, NULL);
			return;
		}
		
		CGFloat constraintW = hasExplicitWidth ? nodeWidth.value : CGFLOAT_MAX;
		CGFloat constraintH = hasExplicitHeight ? nodeHeight.value : CGFLOAT_MAX;
		CGSize constrainedSize = CGSizeMake(constraintW, constraintH);
		CGSize measuredSize = CGSizeZero;
		
		if (![view isKindOfClass:[UIView class]]) {
			measuredSize = [view sizeThatFits:constrainedSize];
			ZDMeasureCacheSetSize(cache, node, measuredSize);
		} else {
			UIView *uiView = (UIView *)view;
			if ([uiView isKindOfClass:[UILabel class]]) {
				// 文本节点：捕获 NSTextStorage 供后台 TextKit 测量
				UILabel *label = (UILabel *)uiView;
				NSTextStorage *textStorage = ZDTextStorageFromLabel(label);
				if (textStorage) {
					ZDMeasureCacheSetTextStorage(cache, node, textStorage, label.numberOfLines);
				} else {
					ZDMeasureCacheSetSize(cache, node, CGSizeZero);
				}
			} else if ([uiView isKindOfClass:[UIImageView class]]) {
				UIImage *image = ((UIImageView *)uiView).image;
				measuredSize = image ? image.size : CGSizeZero;
				ZDMeasureCacheSetSize(cache, node, measuredSize);
			} else {
				measuredSize = [uiView sizeThatFits:constrainedSize];
				ZDMeasureCacheSetSize(cache, node, measuredSize);
			}
		}
		YGNodeSetMeasureFunc(node, YGCachedMeasureView);
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
			YGPreMeasureAndCacheLeafNodes(subview, cache);
		}
	}
}

/// 后台布局完成后恢复所有叶子节点的 measure 函数为标准的 YGMeasureView，
/// 确保后续同步布局能正常调用 sizeThatFits: 进行测量。
static void YGRestoreMeasureFuncs(ZDFlexLayoutView const view) {
	
	ZDFlexLayoutCore *const yoga = view.flexLayout;
	const YGNodeRef node = yoga.node;
	
	if (yoga.isLeaf) {
		YGNodeSetMeasureFunc(node, YGMeasureView);
	} else {
		for (ZDFlexLayoutView subview in view.children) {
			if (subview.flexLayout.isEnabled && subview.flexLayout.isIncludedInLayout) {
				YGRestoreMeasureFuncs(subview);
			}
		}
	}
}

static void YGRemoveAllChildren(const YGNodeRef node) {
	
	if (node == NULL) {
		return;
	}
	
	YGNodeRemoveAllChildren(node);
}

static void YGApplyLayoutToViewHierarchy(ZDFlexLayoutView view, BOOL preserveOrigin) {
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

@end

//-------------------------- Function ------------------------
#pragma mark -

CGFloat ZDFLScreenScale(void) {
	static CGFloat scale = 0.0;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), YES, 0);
		scale = CGContextGetCTM(UIGraphicsGetCurrentContext()).a;
		UIGraphicsEndImageContext();
	});
	return scale;
}

CGFloat ZDFLRoundPixelValue(CGFloat value) {
	CGFloat scale = ZDFLScreenScale();
	return roundf(value * scale) / scale;
}

CGFloat ZDFLCeilPixelValue(CGFloat value) {
	CGFloat scale = ZDFLScreenScale();
	return ceil((value - FLT_EPSILON) * scale) / scale;
}

CGFloat ZDFLFloorPixelValue(CGFloat f) {
	CGFloat scale = ZDFLScreenScale();
	return floor((f + FLT_EPSILON) * scale) / scale;
}
