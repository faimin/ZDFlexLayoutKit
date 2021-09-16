//
//  ZDSFlexLayoutMaker.swift
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/1/19.
//

import Foundation

//MARK: - makeFlexLayout

public extension ZDSFlexNamespace where T: ZDFlexLayoutView {
    
    //MARK: - Maker
    
    @discardableResult
    func makeFlexLayout(_ block: (ZDSFlexLayoutMaker) -> Void) -> T {
        let maker = ZDSFlexLayoutMaker(base.flexLayout)
        block(maker)
        return base
    }
    
    @discardableResult
    func addChild(_ child: ZDFlexLayoutView) -> Self {
        self.base.addChild(child)
        return self
    }
    
    @discardableResult
    func addChildren(_ children: [ZDFlexLayoutView]) -> Self {
        children.forEach { (child) in
            self.addChild(child)
        }
        return self
    }
    
    @discardableResult
    func addChildren(_ children: ZDFlexLayoutView ...) -> Self {
        children.forEach { (child) in
            self.addChild(child)
        }
        return self
    }
}

//MARK: - ZDSFlexLayoutMaker

public struct ZDSFlexLayoutMaker {
    
    private let flexLayout: ZDFlexLayoutCore
    
    public init(_ flexLayout: ZDFlexLayoutCore) {
        flexLayout.isEnabled = true
        self.flexLayout = flexLayout
    }
}

public extension ZDSFlexLayoutMaker {
    
    @discardableResult
    func isEnable(_ isEnable: Bool) -> Self {
        flexLayout.isEnabled = isEnable
        return self
    }
    
    @discardableResult
    func isIncludedInLayout(_ isInclude: Bool) -> Self {
        flexLayout.isIncludedInLayout = isInclude
        return self
    }
    
    //MARK: - Direction
    
    @discardableResult
    func direction(_ direction: YGDirection) -> Self {
        flexLayout.direction = direction
        return self
    }
    
    @discardableResult
    func flexDirection(_ flexDirection: YGFlexDirection) -> Self {
        flexLayout.flexDirection = flexDirection
        return self
    }
    
    @discardableResult
    func justifyContent(_ justifyContent: YGJustify) -> Self {
        flexLayout.justifyContent = justifyContent
        return self
    }
    
    //MARK: - Align
    
    @discardableResult
    func alignContent(_ alignContent: YGAlign) -> Self {
        flexLayout.alignContent = alignContent
        return self
    }
    
    @discardableResult
    func alignItems(_ alignItems: YGAlign) -> Self {
        flexLayout.alignItems = alignItems
        return self
    }
    
    @discardableResult
    func alignSelf(_ alignSelf: YGAlign) -> Self {
        flexLayout.alignSelf = alignSelf
        return self
    }
    
    //MARK: - Postion
    
    @discardableResult
    func position(_ position: YGPositionType) -> Self {
        flexLayout.position = position
        return self
    }
    
    @discardableResult
    func flexWrap(_ flexWrap: YGWrap) -> Self {
        flexLayout.flexWrap = flexWrap
        return self
    }
    
    @discardableResult
    func overflow(_ overflow: YGOverflow) -> Self {
        flexLayout.overflow = overflow
        return self
    }
    
    @discardableResult
    func display(_ display: YGDisplay) -> Self {
        flexLayout.display = display
        return self
    }
    
    //MARK: - Flex
    
    @discardableResult
    func flex(_ flex: CGFloat) -> Self {
        flexLayout.flex = flex
        return self
    }
    
    @discardableResult
    func flexGrow(_ flexGrow: CGFloat) -> Self {
        flexLayout.flexGrow = flexGrow
        return self
    }
    
    @discardableResult
    func flexShrink(_ flexShrink: CGFloat) -> Self {
        flexLayout.flexShrink = flexShrink
        return self
    }
    
    @discardableResult
    func flexBasis(_ flexBasis: YGValue) -> Self {
        flexLayout.flexBasis = flexBasis
        return self
    }
    
    //MARK: - Position
    
    @discardableResult
    func left(_ left: YGValue) -> Self {
        flexLayout.left = left
        return self
    }
    
    @discardableResult
    func right(_ right: YGValue) -> Self {
        flexLayout.right = right
        return self
    }
    
    @discardableResult
    func top(_ top: YGValue) -> Self {
        flexLayout.top = top
        return self
    }
    
    @discardableResult
    func bottom(_ bottom: YGValue) -> Self {
        flexLayout.bottom = bottom
        return self
    }
    
    @discardableResult
    func start(_ start: YGValue) -> Self {
        flexLayout.start = start
        return self
    }
    
    @discardableResult
    func end(_ end: YGValue) -> Self {
        flexLayout.end = end
        return self
    }
    
    //MARK: - Margin
    
    @discardableResult
    func marginLeft(_ marginLeft: YGValue) -> Self {
        flexLayout.marginLeft = marginLeft
        return self
    }
    
    @discardableResult
    func marginRight(_ marginRight: YGValue) -> Self {
        flexLayout.marginRight = marginRight
        return self
    }
    
    @discardableResult
    func marginTop(_ marginTop: YGValue) -> Self {
        flexLayout.marginTop = marginTop
        return self
    }
    
    @discardableResult
    func marginBottom(_ marginBottom: YGValue) -> Self {
        flexLayout.marginBottom = marginBottom
        return self
    }
    
    @discardableResult
    func marginStart(_ marginStart: YGValue) -> Self {
        flexLayout.marginStart = marginStart
        return self
    }
    
    @discardableResult
    func marginEnd(_ marginEnd: YGValue) -> Self {
        flexLayout.marginEnd = marginEnd
        return self
    }
    
    @discardableResult
    func marginHorizontal(_ marginHorizontal: YGValue) -> Self {
        flexLayout.marginHorizontal = marginHorizontal
        return self
    }
    
    @discardableResult
    func marginVertical(_ marginVertical: YGValue) -> Self {
        flexLayout.marginVertical = marginVertical
        return self
    }
    
    @discardableResult
    func margin(_ margin: YGValue) -> Self {
        flexLayout.margin = margin
        return self
    }
    
    //MARK: - Padding
    
    @discardableResult
    func paddingLeft(_ paddingLeft: YGValue) -> Self {
        flexLayout.paddingLeft = paddingLeft
        return self
    }
    
    @discardableResult
    func paddingRight(_ paddingRight: YGValue) -> Self {
        flexLayout.paddingRight = paddingRight
        return self
    }
    
    @discardableResult
    func paddingTop(_ paddingTop: YGValue) -> Self {
        flexLayout.paddingTop = paddingTop
        return self
    }
    
    @discardableResult
    func paddingBottom(_ paddingBottom: YGValue) -> Self {
        flexLayout.paddingBottom = paddingBottom
        return self
    }
    
    @discardableResult
    func paddingStart(_ paddingStart: YGValue) -> Self {
        flexLayout.paddingStart = paddingStart
        return self
    }
    
    @discardableResult
    func paddingEnd(_ paddingEnd: YGValue) -> Self {
        flexLayout.paddingEnd = paddingEnd
        return self
    }
    
    @discardableResult
    func paddingHorizontal(_ paddingHorizontal: YGValue) -> Self {
        flexLayout.paddingHorizontal = paddingHorizontal
        return self
    }
    
    @discardableResult
    func paddingVertical(_ paddingVertical: YGValue) -> Self {
        flexLayout.paddingVertical = paddingVertical
        return self
    }
    
    @discardableResult
    func padding(_ padding: YGValue) -> Self {
        flexLayout.padding = padding
        return self
    }
    
    //MARK: - Border
    
    @discardableResult
    func borderLeftWidth(_ borderLeftWidth: CGFloat) -> Self {
        flexLayout.borderLeftWidth = borderLeftWidth
        return self
    }
    
    @discardableResult
    func borderRightWidth(_ borderRightWidth: CGFloat) -> Self {
        flexLayout.borderRightWidth = borderRightWidth
        return self
    }
    
    @discardableResult
    func borderTopWidth(_ borderTopWidth: CGFloat) -> Self {
        flexLayout.borderTopWidth = borderTopWidth
        return self
    }
    
    @discardableResult
    func borderStartWidth(_ borderStartWidth: CGFloat) -> Self {
        flexLayout.borderStartWidth = borderStartWidth
        return self
    }
    
    @discardableResult
    func borderEndWidth(_ borderEndWidth: CGFloat) -> Self {
        flexLayout.borderEndWidth = borderEndWidth
        return self
    }
    
    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> Self {
        flexLayout.borderWidth = borderWidth
        return self
    }
    
    //MARK: - Size
    
    @discardableResult
    func width(_ width: YGValue) -> Self {
        flexLayout.width = width
        return self
    }
    
    @discardableResult
    func height(_ height: YGValue) -> Self {
        flexLayout.height = height
        return self
    }
    
    @discardableResult
    func minWidth(_ minWidth: YGValue) -> Self {
        flexLayout.minWidth = minWidth
        return self
    }
    
    @discardableResult
    func minHeight(_ minHeight: YGValue) -> Self {
        flexLayout.minHeight = minHeight
        return self
    }
    
    @discardableResult
    func maxWidth(_ maxWidth: YGValue) -> Self {
        flexLayout.maxWidth = maxWidth
        return self
    }
    
    @discardableResult
    func maxHeight(_ maxHeight: YGValue) -> Self {
        flexLayout.maxHeight = maxHeight
        return self
    }
    
    @discardableResult
    func aspectRatio(_ aspectRatio: CGFloat) -> Self {
        flexLayout.aspectRatio = aspectRatio
        return self
    }
    
    @discardableResult
    func markDirty() -> Self {
        flexLayout.markDirty()
        flexLayout.view.notifyRootNeedsLayout()
        return self
    }
    
    @discardableResult
    func gone(_ isGone: Bool) -> Self {
        flexLayout.view.gone = isGone;
        return self;
    }
    
    @discardableResult
    func addChild(_ child: ZDFlexLayoutView) -> Self {
        flexLayout.view.addChild(child)
        return self
    }
    
    @discardableResult
    func addChildren(_ children: [ZDFlexLayoutView]) -> Self {
        children.forEach { (child) in
            addChild(child)
        }
        return self
    }
}
