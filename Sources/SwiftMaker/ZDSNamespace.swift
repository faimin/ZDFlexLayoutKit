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
    
    associatedtype ZDSType: AnyObject
    
    @available(*, deprecated, renamed: "zd")
    var zds: ZDSFlexNamespace<ZDSType> { get set }
    
    var zd: ZDSFlexNamespace<ZDSType> { get set }
}

public extension ZDSFlexObject {
    
    @available(*, deprecated, renamed: "zd")
    var zds: ZDSFlexNamespace<Self> {
        get {
            return ZDSFlexNamespace(self)
        }
        set { }
    }
    
    var zd: ZDSFlexNamespace<Self> {
        get {
            return ZDSFlexNamespace(self)
        }
        set { }
    }
}

extension NSObject: ZDSFlexObject { }

public extension ZDFlexLayoutDiv {
    
    @available(*, deprecated, renamed: "zd")
    static var zds: ZDSFlexNamespace<ZDFlexLayoutDiv> {
        get {
            return ZDSFlexNamespace(Self())
        }
        set { }
    }
    
    static var zd: ZDSFlexNamespace<ZDFlexLayoutDiv> {
        get {
            return ZDSFlexNamespace(Self())
        }
        set { }
    }
}

