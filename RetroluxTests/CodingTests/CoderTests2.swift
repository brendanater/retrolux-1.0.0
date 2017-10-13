//
//  CoderTests2.swift
//  RetroluxTests
//
//  Created by Brendan Henderson on 9/26/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation
import Retrolux
import XCTest

fileprivate protocol CanGoBelowZeroNumber {}

extension Int  : CanGoBelowZeroNumber {}
extension Int8 : CanGoBelowZeroNumber {}
extension Int16: CanGoBelowZeroNumber {}
extension Int32: CanGoBelowZeroNumber {}
extension Int64: CanGoBelowZeroNumber {}

enum CodingType {
    case single
    case unkeyed
    case keyed(stringValue: Bool)
}

protocol TestCodable: Codable {
    
    static var codingType: CodingType {get}
}

class Test: XCTestCase {
    
//    static var encoder: TopLevelEncoder = TestEncoder()
//    static var decoder: TopLevelDecoder = TestDecoder()
//
//    static func values<T: FixedWidthInteger>(for: T.Type) -> [String: T] {
//
//        let type = "\(T.self)"
//
//        var result: [String: T] = [:]
//
//        func add(_ description: String, _ value: T) {
//            result[type + ": " + description] = value
//        }
//
//        add("max", .max)
//        add("min", .min)
//        add("zero", 0)
//        add("positive", 98)
//
//        if T.self is CanGoBelowZeroNumber.Type {
//            add("negative", -51)
//        }
//
//        return result
//    }
//
//    static func values<T: FloatingPoint>(for: T.Type, excludeKeys: [String] = []) -> [String: T] {
//
//        let type = "\(T.self)"
//
//        var result: [String: T] = [:]
//
//        func add(_ description: String, _ value: T, negativeAlso: Bool = true) {
//
//            if excludeKeys.contains(description) {
//                print(description)
//                return
//            }
//
//            let key = type + ": " + description
//
//            result[key] = value
//
//            if negativeAlso {
//                result["-" + key] = -value
//            }
//        }
//
//        add("greatestFiniteMagnitude", .greatestFiniteMagnitude)
//        add("infinity", .infinity)
//        add("leastNonzeroMagnitude", .leastNonzeroMagnitude)
//        add("leastNormalMagnitude", .leastNormalMagnitude)
//        add("nan", .nan)
//        add("pi", .pi)
//        add("signalingNaN", .signalingNaN)
//        add("ulpOfOne", .ulpOfOne)
//        add("zero", 0, negativeAlso: false)
//        add("non-zero", 123)
//
//        return result
//    }
//
//    /// include and exclude keys are the part of the key after "String: "
//    /// do not print this result!
//    static func values(for: String.Type, removeCharactersIn invalidCharacters: String = "", excludeKeys: [String] = [], includeKeys: [String]? = nil) -> [String: String] {
//
//        let type = "String"
//
//        func str(_ name: String, _ set: CharacterSet) -> String {
//            return String(characterSet: set)
//        }
//
//        var result: [String: String] = [:]
//
//        func add(_ description: String, _ value: String) {
//            if let includeKeys = includeKeys {
//
//                guard includeKeys.contains(description) else {
//                    return
//                }
//
//            }
//
//            if excludeKeys.contains(description) {
//                return
//            }
//
//            split(description, value, 1000)
//
//            result[type + ": " + description] = value
//        }
//
//        func add(_ description: String, set: CharacterSet) {
//            var set = set
//            set.remove(charactersIn: invalidCharacters)
//            add(description, String(characterSet: set).prefix(1000).description)
//        }
//
//        add("empty", "")
////        add("test", "throw")
//        add("alphanumerics", set: .alphanumerics)
//        add("controlCharacters", set: .controlCharacters)
//        add("decimalDigits", set: .decimalDigits)
//        add("decomposables", set: .decomposables)
//        add("letters", set: .letters)
//        add("lowercaseLetters", set: .lowercaseLetters)
//        add("newlines", set: .newlines)
//        add("nonBaseCharacters", set: .nonBaseCharacters)
//        add("punctuationCharacters", set: .punctuationCharacters)
//        add("symbols", set: .symbols)
//        add("whitespacesAndNewlines", set: .whitespacesAndNewlines)
//        add("whitespaces", set: .whitespaces)
//        add("urlUserAllowed", set: .urlUserAllowed)
//        add("urlQueryAllowed", set: .urlQueryAllowed)
//        add("urlPathAllowed", set: .urlPathAllowed)
//        add("urlPasswordAllowed", set: .urlPasswordAllowed)
//        add("urlHostAllowed", set: .urlHostAllowed)
//        add("urlFragmentAllowed", set: .urlFragmentAllowed)
//        add("uppercaseLetters", set: .uppercaseLetters)
//
//        return result
//    }
//
//    lazy var intValues   : [String: Int   ] = Test.values(for: Int   .self)
//    lazy var int8Values  : [String: Int8  ] = Test.values(for: Int8  .self)
//    lazy var int16Values : [String: Int16 ] = Test.values(for: Int16 .self)
//    lazy var int32Values : [String: Int32 ] = Test.values(for: Int32 .self)
//    lazy var int64Values : [String: Int64 ] = Test.values(for: Int64 .self)
//    lazy var uintValues  : [String: UInt  ] = Test.values(for: UInt  .self)
//    lazy var uint8Values : [String: UInt8 ] = Test.values(for: UInt8 .self)
//    lazy var uint16Values: [String: UInt16] = Test.values(for: UInt16.self)
//    lazy var uint32Values: [String: UInt32] = Test.values(for: UInt32.self)
//    lazy var uint64Values: [String: UInt64] = Test.values(for: UInt64.self)
//    lazy var floatValues : [String: Float ] = Test.values(for: Float .self)//, excludeKeys: ["signalingNaN", "nan", "infinity"])
//    lazy var doubleValues: [String: Double] = Test.values(for: Double.self)//, excludeKeys: ["signalingNaN", "nan", "infinity"])
//    lazy var stringValues: [String: String] = Test.values(for: String.self)
//
//    var ignoredTypes: [Any.Type] = []
//
//    typealias TestFail = String
//
//    enum RoundTripResult<T: Codable> {
//
//        enum Action {
//            case encodeToValue
//            case encodeToData
//            case decodeFromValue
//            case decodeFromData
//        }
//
//        case result(fromValue: T, fromData: T)
//        case fail(String)
//
//        static func error(_ action: Action, key: String, value: T, error: Error) -> RoundTripResult {
//            return .fail("\n\(action) failure:\nkey: \(key)\nvalue: \(value)\nerror: \(error)\n")
//        }
//    }
//
//    func isValidRepresentation<T: Codable>(_ value: Any, _: T.Type) -> Bool {
//        return value is T
//    }
//
//    enum RoundTripSpecificError: Error {
//
//        case invalidRepresentation(value: Any)
//    }
//
//    func reducedDescription<T>(_ value: T) -> T {
//
//        switch value {
//        case is String:
//            return (value as! String).prefix(100) as! T
//        default:
//            return value
//        }
//    }
//
//    func roundTrip<T: Codable>(key: String, value: T) -> RoundTripResult<T> {
//
//        let _value: Any
//
//        do {
//            _value = try Test.encoder.encode(value: value)
//
//            guard isValidRepresentation(_value, T.self) else {
//                return RoundTripResult.error(.encodeToValue, key: key, value: value, error: RoundTripSpecificError.invalidRepresentation(value: reducedDescription(value)))
//            }
//
//        } catch let error as EncodingError {
//            var error = error
//
//            switch error {
//            case .invalidValue(let _value, let context):
//                error = .invalidValue(reducedDescription(_value), context)
//            }
//
//            return RoundTripResult.error(.encodeToValue, key: key, value: value, error: error)
//
//        } catch {
//
//            return RoundTripResult.error(.encodeToValue, key: key, value: value, error: error)
//        }
//
//        let data: Data
//
//        do {
//            data = try Test.encoder.encode(data: value)
//
//        } catch let error as EncodingError {
//            var error = error
//
//            switch error {
//            case .invalidValue(let _value, let context):
//                error = .invalidValue(reducedDescription(_value), context)
//            }
//
//            return RoundTripResult.error(.encodeToValue, key: key, value: value, error: error)
//
//        } catch {
//
//            return RoundTripResult.error(.encodeToValue, key: key, value: value, error: error)
//        }
//
//        let fromValueResult: T
//
//        do {
//            fromValueResult = try Test.decoder.decode(T.self, fromValue: _value)
//
//        } catch {
//
//            return RoundTripResult.error(.decodeFromValue, key: key, value: value, error: error)
//        }
//
//        do {
//
//            let fromDataResult = try Test.decoder.decode(T.self, from: data)
//
//            return RoundTripResult.result(fromValue: fromValueResult, fromData: fromDataResult)
//
//        } catch {
//
//            return RoundTripResult.error(.decodeFromData, key: key, value: value, error: error)
//        }
//    }
//
//    // roundTrip
//
//    func _roundTrip<T: Codable>(_ values: [String: T], isEqual: (T, T)->Bool) -> [TestFail] {
//
//        var fails: [TestFail] = []
//
//        for (key, value) in values {
//
//            switch roundTrip(key: key, value: value) {
//
//            case let .result(fromValue: fromValueResult, fromData: fromDataResult):
//                if !isEqual(value, fromValueResult) {
//                    fails.append("\(T.self) from value failed:\nkey: \(key)\nvalue: \(value)\nerror: unequal result: \(fromValueResult)")
//                }
//                if !isEqual(value, fromDataResult) {
//                    fails.append("\(T.self) from data failed:\nkey: \(key)\nvalue: \(value)\nerror: unequal result: \(fromDataResult)")
//                }
//
//            case .fail(let fail):
//                fails.append(fail)
//            }
//        }
//
//        return fails
//    }
//
//    struct Allows {
//        let single: Bool
//        let unkeyed: Bool
//        let keyed: Bool
//        let keyedUsesStringValue: Bool
//    }
//
//    static var topLevelAllows = Allows(single: false, unkeyed: true, keyed: true, keyedUsesStringValue: true)
//
//    /// test a list of values and return nil or errors as String in format:
//    /// -- tests failed: fails.count
//    /// description, value:
//    /// error
//    /// --
//    /// description, value:
//    /// error
//    /// --
//    /// Zero, 0:
//    /// failedToEncode(Error)
//    /// --
//    /// String, "":
//    /// failedToEncode(Error)
//    /// --
//
//
//    func codingType<T: Codable>(for: T.Type) -> CodingType {
//
//        if T.self is Array<Any>.Type {
//            return .unkeyed
//        } else if T.self is Dictionary<String, Any>.Type {
//            return .keyed(stringValue: true)
//        } else if T.self is Dictionary<Int, Any>.Type {
//            return .keyed(stringValue: false)
//        } else if let type = T.self as? TestCodable.Type {
//            return type.codingType
//        } else {
//            return .single
//        }
//    }
//
//    /// nests the single value in an array or dictionary based on Self.topLevelAllows
//    func roundTrip<T: Codable>(_ values: [String: T], isEqual: (T, T)->Bool) -> [TestFail] {
//
//        let codingType: CodingType = self.codingType(for: T.self)
//
//        if Test.topLevelAllows.single {
//
//            return _roundTrip(values, isEqual: isEqual)
//
//        } else if Test.topLevelAllows.unkeyed {
//
//            switch codingType {
//
//            case .single:
//
//                var result: [String: [T]] = [:]
//
//                for (key, value) in values {
//                    result[key] = [value]
//                }
//
//                return _roundTrip(result, isEqual: { isEqual($0.first!, $1.first!) })
//
//            default:
//                return _roundTrip(values, isEqual: isEqual)
//            }
//
//        } else {
//
//            assert(Test.topLevelAllows.keyed, "\(type(of: self)) doesn't allow coding anything!?")
//
//            switch codingType {
//
//            case .single, .unkeyed:
//
//                if Test.topLevelAllows.keyedUsesStringValue {
//
//                    var result: [String: [String: T]] = [:]
//
//                    for (key, value) in values {
//                        result[key] = ["test": value]
//                    }
//
//                    return _roundTrip(result, isEqual: { isEqual($0.first!.value, $1.first!.value) })
//
//                } else {
//
//                    var result: [String: [Int: T]] = [:]
//
//                    for (key, value) in values {
//                        result[key] = [1: value]
//                    }
//
//                    return _roundTrip(result, isEqual: { isEqual($0.first!.value, $1.first!.value) })
//                }
//
//            default:
//                return _roundTrip(values, isEqual: isEqual)
//            }
//        }
//    }
//
//    func roundTrip<T: Codable & Equatable>(_ values: [String: T]) -> [TestFail] {
//
//        return roundTrip(values, isEqual: { $0 == $1 })
//    }
//
//    typealias ValuesType<T: Codable> = (values: [String: T], (T,T)->Bool)
//
//    func array<T: Codable>(_ values: ValuesType<T>) -> ValuesType<[T]> {
//
//    }
//
//    func roundTrip<T: Codable>(asArray values: [String: T], isEqual: (T, T)->Bool) -> [TestFail] {
//
//        var errors: [TestFail] = []
//
//        func same(value1: )
//
//        errors += roundTrip(array(values), isEqual: {
//
//            if $0.count != $1.count {
//                return false
//            }
//
//            for (one, two) in zip($0, $1) {
//                if !isEqual($0, $1) {
//                    return false
//                }
//            }
//
//            return true
//
//        })
//
//        errors += roundTrip(array(array(values)), isEqual: isEqual)
//
//        return errors
//    }
//
//    func testRoundTrips() {
//
//        let fails = roundTripsTest()
//
//        if !fails.isEmpty { XCTFail("\n\nroundTrips failed. count: \(fails.count)\n\n" + fails.joined(separator: "\n\n")) }
//
//    }
//
//    func roundTripsTest() -> [TestFail] {
//
//        var errors: [TestFail] = []
//
//        // single
//        errors += roundTrip(intValues   )
//        errors += roundTrip(int8Values  )
//        errors += roundTrip(int16Values )
//        errors += roundTrip(int32Values )
//        errors += roundTrip(int64Values )
//        errors += roundTrip(uintValues  )
//        errors += roundTrip(uint8Values )
//        errors += roundTrip(uint16Values)
//        errors += roundTrip(uint32Values)
//        errors += roundTrip(uint64Values)
//        errors += roundTrip(floatValues )
//        errors += roundTrip(doubleValues)
//        errors += roundTrip(stringValues)
//
//        // unkeyed
//        errors += roundTrip(asArray: intValues   )
//        errors += roundTrip(int8Values  )
//        errors += roundTrip(int16Values )
//        errors += roundTrip(int32Values )
//        errors += roundTrip(int64Values )
//        errors += roundTrip(uintValues  )
//        errors += roundTrip(uint8Values )
//        errors += roundTrip(uint16Values)
//        errors += roundTrip(uint32Values)
//        errors += roundTrip(uint64Values)
//        errors += roundTrip(floatValues )
//        errors += roundTrip(doubleValues)
//        errors += roundTrip(stringValues)
//
//
//        otherRoundTrips(&errors)
//
//        return errors
//    }
//
//    func otherRoundTrips(_ errors: inout [TestFail]) {
//    }
}








