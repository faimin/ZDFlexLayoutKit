//
//  ZDSNamespace.swift
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2021/1/19.
//

import Foundation

public struct ZDSFlexNamespace<T> {
    
    public let base: T
    
    public init(_ base: T) {
        self.base = base
    }
}

public protocol ZDSFlexObject: AnyObject {
    
    associatedtype ZDSType
    
    var zds: ZDSFlexNamespace<ZDSType> { get set }
    
    static var zds: ZDSFlexNamespace<ZDSType>.Type { get set }
}

public extension ZDSFlexObject {
    
    var zds: ZDSFlexNamespace<Self> {
        get {
            return ZDSFlexNamespace(self)
        }
        set { }
    }
    
    static var zds: ZDSFlexNamespace<Self>.Type {
        get {
            return ZDSFlexNamespace<Self>.self
        }
        set { }
    }
}

extension NSObject: ZDSFlexObject {}
