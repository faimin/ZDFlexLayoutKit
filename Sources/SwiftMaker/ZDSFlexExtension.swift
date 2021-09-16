//
//  ZDSFlexExtension.swift
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2020/12/5.
//

import yoga
postfix operator %

extension Int {
    public static postfix func %(value: Int) -> YGValue {
        return YGValue(value: Float(value), unit: .percent)
    }
}

extension Float {
    public static postfix func %(value: Float) -> YGValue {
        return YGValue(value: value, unit: .percent)
    }
}

extension Double {
    public static postfix func %(value: Double) -> YGValue {
        return YGValue(value: Float(value), unit: .percent)
    }
}

extension CGFloat {
    public static postfix func %(value: CGFloat) -> YGValue {
        return YGValue(value: Float(value), unit: .percent)
    }
}

extension YGValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public init(integerLiteral value: Int) {
        self = YGValue(value: Float(value), unit: .point)
    }
    
    public init(floatLiteral value: Float) {
        self = YGValue(value: value, unit: .point)
    }
    
    public init(_ value: Float) {
        self = YGValue(value: value, unit: .point)
    }
    
    public init(_ value: Double) {
        self = YGValue(value: Float(value), unit: .point)
    }
    
    public init(_ value: CGFloat) {
        self = YGValue(value: Float(value), unit: .point)
    }
}
