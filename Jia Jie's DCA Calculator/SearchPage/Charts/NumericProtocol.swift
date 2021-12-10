//
//  NumericProtocol.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/12/21.
//

import Foundation
import CoreGraphics

protocol CustomNumeric : Comparable, SignedNumeric {

    init(_ v:Float)
    init(_ v:Double)
    init(_ v:Int)
    init(_ v:UInt)
    init(_ v:Int8)
    init(_ v:UInt8)
    init(_ v:Int16)
    init(_ v:UInt16)
    init(_ v:Int32)
    init(_ v:UInt32)
    init(_ v:Int64)
    init(_ v:UInt64)
    init(_ v:CGFloat)

    // 'shadow method' that allows instances of Numeric
    // to coerce themselves to another Numeric type
    func _asOther<T:CustomNumeric>() -> T
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}

extension CustomNumeric {

    // Default implementation of init(fromNumeric:) simply gets the inputted value
    // to coerce itself to the same type as the initialiser is called on
    // (the generic parameter T in _asOther() is inferred to be the same type as self)
    init<T:CustomNumeric>(fromNumeric numeric: T) { self = numeric._asOther() }
}



extension Float   : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension Double  : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension CGFloat : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension Int     : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension Int8    : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension Int16   : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension Int32   : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension Int64   : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension UInt    : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension UInt8   : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension UInt16  : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension UInt32  : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}
extension UInt64  : CustomNumeric {func _asOther<T:CustomNumeric>() -> T { return T(self) }}


