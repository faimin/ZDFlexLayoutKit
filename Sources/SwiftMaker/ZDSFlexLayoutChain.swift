//
//  ZDSFlexLayoutChain.swift
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2020/12/5.
//

import Foundation

/*
public extension ZDSFlexNamespace where T: ZDFlexLayoutView {
    
    @discardableResult
    func isEnable(_ enable: Bool) -> Self {
        base.flexLayout.isEnabled = enable
        return self
    }
    
    @discardableResult
    func isIncludedInLayout(_ isInclude: Bool) -> Self {
        base.flexLayout.isIncludedInLayout = isInclude
        return self
    }
    
    //MARK: - Direction
    
    @discardableResult
    func direction(_ direction: YGDirection) -> Self {
        base.flexLayout.direction = direction
        return self
    }
    
    @discardableResult
    func flexDirection(_ flexDirection: YGFlexDirection) -> Self {
        base.flexLayout.flexDirection = flexDirection
        return self
    }
    
    @discardableResult
    func justifyContent(_ justifyContent: YGJustify) -> Self {
        base.flexLayout.justifyContent = justifyContent
        return self
    }
    
    //MARK: - Align
    
    @discardableResult
    func alignContent(_ alignContent: YGAlign) -> Self {
        base.flexLayout.alignContent = alignContent
        return self
    }
    
    @discardableResult
    func alignItems(_ alignItems: YGAlign) -> Self {
        base.flexLayout.alignItems = alignItems
        return self
    }
    
    @discardableResult
    func alignSelf(_ alignSelf: YGAlign) -> Self {
        base.flexLayout.alignSelf = alignSelf
        return self
    }
    
    //MARK: - Postion
    
    @discardableResult
    func position(_ position: YGPositionType) -> Self {
        base.flexLayout.position = position
        return self
    }
    
    @discardableResult
    func flexWrap(_ flexWrap: YGWrap) -> Self {
        base.flexLayout.flexWrap = flexWrap
        return self
    }
    
    @discardableResult
    func overflow(_ overflow: YGOverflow) -> Self {
        base.flexLayout.overflow = overflow
        return self
    }
    
    @discardableResult
    func display(_ display: YGDisplay) -> Self {
        base.flexLayout.display = display
        return self
    }
    
    //MARK: - Flex
    
    @discardableResult
    func flex(_ flex: CGFloat) -> Self {
        base.flexLayout.flex = flex
        return self
    }
    
    @discardableResult
    func flexGrow(_ flexGrow: CGFloat) -> Self {
        base.flexLayout.flexGrow = flexGrow
        return self
    }
    
    @discardableResult
    func flexShrink(_ flexShrink: CGFloat) -> Self {
        base.flexLayout.flexShrink = flexShrink
        return self
    }
    
    @discardableResult
    func flexBasis(_ flexBasis: YGValue) -> Self {
        base.flexLayout.flexBasis = flexBasis
        return self
    }
    
    //MARK: - Position
    
    @discardableResult
    func left(_ left: YGValue) -> Self {
        base.flexLayout.left = left
        return self
    }
    
    @discardableResult
    func right(_ right: YGValue) -> Self {
        base.flexLayout.right = right
        return self
    }
    
    @discardableResult
    func top(_ top: YGValue) -> Self {
        base.flexLayout.top = top
        return self
    }
    
    @discardableResult
    func bottom(_ bottom: YGValue) -> Self {
        base.flexLayout.bottom = bottom
        return self
    }
    
    @discardableResult
    func start(_ start: YGValue) -> Self {
        base.flexLayout.start = start
        return self
    }
    
    @discardableResult
    func end(_ end: YGValue) -> Self {
        base.flexLayout.end = end
        return self
    }
    
    //MARK: - Margin
    
    @discardableResult
    func marginLeft(_ marginLeft: YGValue) -> Self {
        base.flexLayout.marginLeft = marginLeft
        return self
    }
    
    @discardableResult
    func marginRight(_ marginRight: YGValue) -> Self {
        base.flexLayout.marginRight = marginRight
        return self
    }
    
    @discardableResult
    func marginTop(_ marginTop: YGValue) -> Self {
        base.flexLayout.marginTop = marginTop
        return self
    }
    
    @discardableResult
    func marginBottom(_ marginBottom: YGValue) -> Self {
        base.flexLayout.marginBottom = marginBottom
        return self
    }
    
    @discardableResult
    func marginStart(_ marginStart: YGValue) -> Self {
        base.flexLayout.marginStart = marginStart
        return self
    }
    
    @discardableResult
    func marginEnd(_ marginEnd: YGValue) -> Self {
        base.flexLayout.marginEnd = marginEnd
        return self
    }
    
    @discardableResult
    func marginHorizontal(_ marginHorizontal: YGValue) -> Self {
        base.flexLayout.marginHorizontal = marginHorizontal
        return self
    }
    
    @discardableResult
    func marginVertical(_ marginVertical: YGValue) -> Self {
        base.flexLayout.marginVertical = marginVertical
        return self
    }
    
    @discardableResult
    func margin(_ margin: YGValue) -> Self {
        base.flexLayout.margin = margin
        return self
    }
    
    //MARK: - Padding
    
    @discardableResult
    func paddingLeft(_ paddingLeft: YGValue) -> Self {
        base.flexLayout.paddingLeft = paddingLeft
        return self
    }
    
    @discardableResult
    func paddingRight(_ paddingRight: YGValue) -> Self {
        base.flexLayout.paddingRight = paddingRight
        return self
    }
    
    @discardableResult
    func paddingTop(_ paddingTop: YGValue) -> Self {
        base.flexLayout.paddingTop = paddingTop
        return self
    }
    
    @discardableResult
    func paddingBottom(_ paddingBottom: YGValue) -> Self {
        base.flexLayout.paddingBottom = paddingBottom
        return self
    }
    
    @discardableResult
    func paddingStart(_ paddingStart: YGValue) -> Self {
        base.flexLayout.paddingStart = paddingStart
        return self
    }
    
    @discardableResult
    func paddingEnd(_ paddingEnd: YGValue) -> Self {
        base.flexLayout.paddingEnd = paddingEnd
        return self
    }
    
    @discardableResult
    func paddingHorizontal(_ paddingHorizontal: YGValue) -> Self {
        base.flexLayout.paddingHorizontal = paddingHorizontal
        return self
    }
    
    @discardableResult
    func paddingVertical(_ paddingVertical: YGValue) -> Self {
        base.flexLayout.paddingVertical = paddingVertical
        return self
    }
    
    @discardableResult
    func padding(_ padding: YGValue) -> Self {
        base.flexLayout.padding = padding
        return self
    }
    
    //MARK: - Border
    
    @discardableResult
    func borderLeftWidth(_ borderLeftWidth: CGFloat) -> Self {
        base.flexLayout.borderLeftWidth = borderLeftWidth
        return self
    }
    
    @discardableResult
    func borderRightWidth(_ borderRightWidth: CGFloat) -> Self {
        base.flexLayout.borderRightWidth = borderRightWidth
        return self
    }
    
    @discardableResult
    func borderTopWidth(_ borderTopWidth: CGFloat) -> Self {
        base.flexLayout.borderTopWidth = borderTopWidth
        return self
    }
    
    @discardableResult
    func borderStartWidth(_ borderStartWidth: CGFloat) -> Self {
        base.flexLayout.borderStartWidth = borderStartWidth
        return self
    }
    
    @discardableResult
    func borderEndWidth(_ borderEndWidth: CGFloat) -> Self {
        base.flexLayout.borderEndWidth = borderEndWidth
        return self
    }
    
    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> Self {
        base.flexLayout.borderWidth = borderWidth
        return self
    }
    
    //MARK: - Size
    
    @discardableResult
    func width(_ width: YGValue) -> Self {
        base.flexLayout.width = width
        return self
    }
    
    @discardableResult
    func height(_ height: YGValue) -> Self {
        base.flexLayout.height = height
        return self
    }
    
    @discardableResult
    func minWidth(_ minWidth: YGValue) -> Self {
        base.flexLayout.minWidth = minWidth
        return self
    }
    
    @discardableResult
    func minHeight(_ minHeight: YGValue) -> Self {
        base.flexLayout.minHeight = minHeight
        return self
    }
    
    @discardableResult
    func maxWidth(_ maxWidth: YGValue) -> Self {
        base.flexLayout.maxWidth = maxWidth
        return self
    }
    
    @discardableResult
    func maxHeight(_ maxHeight: YGValue) -> Self {
        base.flexLayout.maxHeight = maxHeight
        return self
    }
    
    @discardableResult
    func aspectRatio(_ aspectRatio: CGFloat) -> Self {
        base.flexLayout.aspectRatio = aspectRatio
        return self
    }
    
    @discardableResult
    func markDirty() -> Self {
        base.flexLayout.markDirty()
        base.notifyRootNeedsLayout()
        return self
    }
    
    @discardableResult
    func addChild(_ child: ZDFlexLayoutView) -> Self {
        base.addChild(child)
        return self
    }
    
    @discardableResult
    func addChildren(_ children: [ZDFlexLayoutView]) -> Self {
        children.forEach { (child) in
            base.addChild(child)
        }
        return self
    }
}
*/
