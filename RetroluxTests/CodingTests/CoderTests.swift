//
//  CoderTests.swift
//  SimplifiedCoderTests
//
//  Created by Brendan Henderson on 9/22/17.
//  Copyright © 2017 OKAY. All rights reserved.
//

import Foundation
import XCTest
@testable import Retrolux



//class EncoderPathTests: XCTestCase {
//
//    var encoder: TopLevelEncoder = TestEncoder()
//    var decoder: TopLevelDecoder = TestDecoder()
//
//
//
//
//}


class TestExpectedPaths: XCTestCase {
    
    func newEncoder() -> JSONEncoder {
        return JSONEncoder()
    }
    
    func newDecoder() -> JSONDecoder {
        return JSONDecoder()
    }
    
    typealias Objects = CoderTesting.Objects
    
    func testEncodePaths() {
        
        self.startEncodePathTest(with: Float.infinity  )
        self.startEncodePathTest(with: Double.infinity )
        // .nan != .nan
        self.startEncodePathTest(with: Date()          )
        self.startEncodePathTest(with: Data()          )
        
        self.startEncodePathTest(with: Objects.VisualCheck())
    }
    
    func testDecodePaths() {
        
        self.startDecodePathTest(with: Float    .self, from: "test"     , errorType: .typeMismatch(Float  .self))
        self.startDecodePathTest(with: Int      .self, from: UInt64.max , errorType: .dataCorrupted)// number does not fit
        self.startDecodePathTest(with: UInt     .self, from: -1         , errorType: .dataCorrupted)// number does not fit
        self.startDecodePathTest(with: Bool     .self, from: 2          , errorType: .typeMismatch(Bool   .self))
        self.startDecodePathTest(with: Double   .self, from: "test"     , errorType: .typeMismatch(Double .self))
        self.startDecodePathTest(with: String   .self, from: 1          , errorType: .typeMismatch(String .self))
        self.startDecodePathTest(with: URL      .self, from: "%"        , errorType: .dataCorrupted)// invalid url
        self.startDecodePathTest(with: Decimal  .self, from: "test"     , errorType: .typeMismatch(Double.self)) // try decode as Double
        // .nan != .nan
        self.startDecodePathTest(with: Date.self, from: "test", errorType: .typeMismatch(Date.self))
        self.startDecodePathTest(with: Data.self, from: 1     , errorType: .typeMismatch(Data.self))

        self.startDecodePathTest(with: Objects.VisualCheck.self         , from: "test"          , errorType: .valueNotFound(Objects.VisualCheck.self))
        self.startDecodePathTest(with: Objects.KeyNotFoundCheck.self    , from: ["test": true]  , errorType: .keyNotFound(stringValue: "1000", intValue: 1000))
        self.startDecodePathTest(with: Objects.UnkeyedIsAtEndCheck.self , from: [true]          , errorType: .valueNotFound(Objects.UnkeyedIsAtEndCheck.self))
    }
    
    func startEncodePathTest<T: Encodable>(with value: T) {
        
        self.encodePathTest(value, expected: type(of: value), currentCount: 0)
    }
    
    func startDecodePathTest<T: Decodable, E>(with decodable: T.Type, from value: E, errorType: CoderTesting.DecodingErrorType) {
        
        self.decodePathTest(decodable, from: value, expected: decodable, errorType: errorType, currentCount: 0)
    }
    
    func encodePathTest<T: Encodable, E: Encodable>(_ value: E, expected: T.Type, currentCount: Int) {
        
        /// print where the fail is.
        func willFail() {
            print("will fail at:", type(of: value), expected)
        }
        
        let stats = try! CoderTesting.encodeStats(expected: expected, encodable: value)
        
        if stats.willCrashIfJSONEncoder {
            return
        }
        
        switch stats.topLevelType {
        case .keyed, .unkeyed:
            
            do {
                
                let encoder = self.newEncoder()
                
                encoder.dateEncodingStrategy = .custom { throw EncodingError.invalidValue($0, EncodingError.Context(codingPath: $1.codingPath, debugDescription: "threw at path")) }
                encoder.dataEncodingStrategy = .custom { throw EncodingError.invalidValue($0, EncodingError.Context(codingPath: $1.codingPath, debugDescription: "threw at path")) }
                
                _ = try encoder.encode(value)
                
                willFail()
                XCTFail("failed to throw")
                return
                
            } catch let error as EncodingError {
                
                guard type(of: error.value) == expected else {
                    willFail()
                    XCTFail("unexpected invalidValue: \(type(of: error.value)) expected: \(expected)")
                    return
                }
                
                if let fail = CoderTesting.guardEqual(expected: error.context.codingPath, actual: stats.codingPathOfFirstExpected!) {
                    willFail()
                    XCTFail(fail.description)
                    return
                }
                
            } catch {
                willFail()
                XCTFail("\(error)")
                return
            }
            
        case .single: break
        }
        
        if currentCount < 3 {
            self.encodePathTest(Objects.Single(value)                   , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.Keyed(key: 1, value: value)     , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.SubKeyed1(key: 1, value: value) , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.SubKeyed2(key: 1, value: value) , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.Unkeyed(value)                  , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.SubUnkeyed1(value)              , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.SubUnkeyed2(value)              , expected: expected, currentCount: currentCount + 1)
            self.encodePathTest(Objects.MultipleStore(value)            , expected: expected, currentCount: currentCount + 1)
        }
    }

    func decodePathTest<T: Decodable, D: Decodable, E>(_ decodable: D.Type, from value: E, expected: T.Type, errorType: CoderTesting.DecodingErrorType, currentCount: Int) {
        
        func willFail() {
            print("will fail:", decodable, type(of: value), expected, errorType)
        }
        
        let stats = try! CoderTesting.decodeStats(expected: expected, decodable: decodable)
        
        switch stats.topLevelType {
            
        case .keyed, .unkeyed:
            
            do {
                
                guard JSONSerialization.isValidJSONObject(value) else {
                    willFail()
                    XCTFail("\(type(of: value)) is not a valid JSON object")
                    return
                }
                
                let data = try JSONSerialization.data(withJSONObject: value)
                
                let decoder = self.newDecoder()
                
                decoder.dateDecodingStrategy = .custom { throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: $0.codingPath, debugDescription: "threw at path")) }
                decoder.dataDecodingStrategy = .custom { throw DecodingError.typeMismatch(Data.self, DecodingError.Context(codingPath: $0.codingPath, debugDescription: "threw at path")) }
                
                _ = try decoder.decode(decodable, from: data)
                
                willFail()
                XCTFail("failed to throw")
                
            } catch let error as DecodingError {
                
                guard errorType.isCorrect(error) else {
                    willFail()
                    XCTFail("incorrect error type. expected: \(errorType) actual: \(error)")
                    return
                }
                
                if let fail = CoderTesting.guardEqual(expected: error.context.codingPath, actual: stats.codingPathOfFirstExpected!) {
                    willFail()
                    XCTFail(fail.description)
                    return
                }
            } catch {
                willFail()
                XCTFail("\(error)")
            }
            
        default: break
        }

        if currentCount < 3 {
            
            self.decodePathTest(Objects.Single<D>.self        , from: value                   , expected: expected, errorType: errorType, currentCount: currentCount + 1)
            self.decodePathTest(Objects.Keyed<Int, D>.self    , from: ["1": value]            , expected: expected, errorType: errorType, currentCount: currentCount + 1)
            self.decodePathTest(Objects.SubKeyed1<Int, D>.self, from: ["1": value]            , expected: expected, errorType: errorType, currentCount: currentCount + 1)
            self.decodePathTest(Objects.SubKeyed2<Int, D>.self, from: ["super": ["1": value]] , expected: expected, errorType: errorType, currentCount: currentCount + 1)
            self.decodePathTest(Objects.Unkeyed<D>.self       , from: [value]                 , expected: expected, errorType: errorType, currentCount: currentCount + 1)
            self.decodePathTest(Objects.SubUnkeyed1<D>.self   , from: [value]                 , expected: expected, errorType: errorType, currentCount: currentCount + 1)
            self.decodePathTest(Objects.SubUnkeyed2<D>.self   , from: [[value]]               , expected: expected, errorType: errorType, currentCount: currentCount + 1)
        }
    }
        
        
        
        
        
        
//        if let fail = self.basicPathTest() { XCTFail(fail.description) }
        
        
//        if let fail = self.path(jsonInvalidContaining: pathValue) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: ["test": pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }
//        if let fail = self.path(jsonInvalidContaining: [pathValue]) { XCTFail("\n" + fail.description + "\n") }

//        let v = throwingObject

        // array
//        single: if let fail = path([v]) { XCTFail(fail.description) }
//        nested: if let fail = path([[[[[[v]]], [[[v]]]]]]) { XCTFail(fail.description) }
//
//        // dictionary
//        single: if let fail = path(["1": v]) { XCTFail(fail.description) }
//        nested: if let fail = path([[[[[[v]]], [[[v]]]]]]) { XCTFail(fail.description) }
//
//        // mixed array and dictionary
//        arrayFirst: if let fail = path([["1": v]]) { XCTFail(fail.description) }
//        dictionaryFirst: if let fail = path(["1": [v]]) { XCTFail(fail.description) }
//        arrayDictArray: if let fail = path([["1": ["1": v]]]) { XCTFail(fail.description) }
//        dictArrayDict: if let fail = path(["1": [["1": v]]]) { XCTFail(fail.description) }
        
        

        // objects
//        if let fail = path(Objects.Single(value: v)) { XCTFail(fail.description) } // JSONSerialization cannot handle single top-level objects
//        if let fail = path(Objects.Keyed(value: v)) { XCTFail(fail.description) }
//        if let fail = path(Objects.Unkeyed(value: v)) { XCTFail(fail.description) }
//        if let fail = path(Objects.NestedKeyed(value: v)) { XCTFail(fail.description) }
//        if let fail = path(Objects.NestedUnkeyed(value: v)) { XCTFail(fail.description) }
//        if let fail = path(Objects.SubKeyed(value: v)) { XCTFail(fail.description) }
//        if let fail = path(Objects.SubUnkeyed(value: v)) { XCTFail(fail.description) }
        
//        if let fail = self.pathTest([1], expected: [.index(0)]) { XCTFail(fail) }
        
        
        
//        print(self.pathTest([1], stringValues: [.index(0), .index(0)]) ?? "no error")
        
//        print(encoder.pathTest(value: [1]))
//        print(encoder.pathTest(value: 1))
//    }
    
    
//
//    var encoder2: TopLevelEncoder = TestEncoder()
//    var decoder2: TopLevelDecoder = TestDecoder()
//
//    func testRoundTripJSON() {
//
//        if let fail = roundTrip(["test"]) { XCTFail(fail.description) }
//        if let fail = roundTrip([true]) { XCTFail(fail.description) }
//        if let fail = roundTrip([UInt64.max, UInt64.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip([String?.none, String?.some("test")]) { XCTFail(fail.description) }
//        if let fail = roundTrip([Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, 0, Float.leastNormalMagnitude, Float.leastNonzeroMagnitude]) { XCTFail(fail.description) }
//        if let fail = roundTrip([Double.greatestFiniteMagnitude, -Double.greatestFiniteMagnitude, 0, Double.leastNormalMagnitude, Double.leastNonzeroMagnitude]) { XCTFail(fail.description) }
//        if let fail = roundTrip([Int8.max, Int8.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip([UInt8.max, UInt8.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip([Int.max, Int.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip([UInt.max, UInt.min]) { XCTFail(fail.description) }
//
//        // array
//        single: if let fail = roundTrip([1]) { XCTFail(fail.description) }
//        multiple: if let fail = roundTrip([1, 2, 3, 4, 5]) { XCTFail(fail.description) }
//        nested: if let fail = roundTrip([[[[[[1]]], [[[2]]]]]]) { XCTFail(fail.description) }
//
//        // dictionary
//        single: if let fail = roundTrip([1: 1]) { XCTFail(fail.description) }
//        multiple: if let fail = roundTrip(asDictionary([1, 2, 3, 4, 5])) { XCTFail(fail.description) }
//        nested: if let fail = roundTrip(asDictionary([[[[[[1]]], [[[2]]]]]])) { XCTFail(fail.description) }
//
//        // mixed array and dictionary
//        arrayFirst: if let fail = roundTrip([[1: 1]]) { XCTFail(fail.description) }
//        dictionaryFirst: if let fail = roundTrip([1: [1]]) { XCTFail(fail.description) }
//        arrayDictArray: if let fail = roundTrip([[1: [1: 1]]]) { XCTFail(fail.description) }
//        dictArrayDict: if let fail = roundTrip([1: [[1: 1]]]) { XCTFail(fail.description) }
//
//        // objects
//        if let fail = roundTrip([Objects.Single()]) { XCTFail(fail.description) }
//        if let fail = roundTrip(Objects.Keyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip(Objects.Unkeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip(Objects.NestedKeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip(Objects.NestedUnkeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip(Objects.SubKeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip(Objects.SubUnkeyed()) { XCTFail(fail.description) }
//    }
//
//    func testPathJSON() {
//
//        let v = Float.infinity
//
//        // array
//        single: if let fail = path([v]) { XCTFail(fail.description) }
//        nested: if let fail = path([[[[[[1 as Float]]], [[[v]]]]]]) { XCTFail(fail.description) }
//
//        // dictionary
//        single: if let fail = path(["1": v]) { XCTFail(fail.description) }
//        nested: if let fail = path(asStringDictionary([[[[[[v]]], [[[1 as Float]]]]]])) { XCTFail(fail.description) }
//
//        // mixed array and dictionary
//        arrayFirst: if let fail = path([["1": v]]) { XCTFail(fail.description) }
//        dictionaryFirst: if let fail = path(["1": [v]]) { XCTFail(fail.description) }
//        arrayDictArray: if let fail = path([["1": ["1": v]]]) { XCTFail(fail.description) }
//        dictArrayDict: if let fail = path(["1": [["1": v]]]) { XCTFail(fail.description) }
//
//        // objects
//        if let fail = path([Objects.Throwing.Single()]) { XCTFail(fail.description) } // JSONSerialization cannot handle single top-level objects
//        if let fail = path(Objects.Throwing.Keyed()) { XCTFail(fail.description) }
//        if let fail = path(Objects.Throwing.Unkeyed()) { XCTFail(fail.description) }
//        if let fail = path(Objects.Throwing.NestedKeyed()) { XCTFail(fail.description) }
//        if let fail = path(Objects.Throwing.NestedUnkeyed()) { XCTFail(fail.description) }
//        if let fail = path(Objects.Throwing.SubKeyed()) { XCTFail(fail.description) }
//        if let fail = path(Objects.Throwing.SubUnkeyed()) { XCTFail(fail.description) }
//    }
//
//    func testRoundTrip() {
//
//        if let fail = roundTrip2(["test"]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([true]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([UInt64.max, UInt64.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([String?.none, String?.some("test")]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, 0, Float.leastNormalMagnitude, Float.leastNonzeroMagnitude]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([Double.greatestFiniteMagnitude, -Double.greatestFiniteMagnitude, 0, Double.leastNormalMagnitude, Double.leastNonzeroMagnitude]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([Int8.max, Int8.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([UInt8.max, UInt8.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([Int.max, Int.min]) { XCTFail(fail.description) }
//        if let fail = roundTrip2([UInt.max, UInt.min]) { XCTFail(fail.description) }
//
//        // array
//        single: if let fail = roundTrip2([1]) { XCTFail(fail.description) }
//        multiple: if let fail = roundTrip2([1, 2, 3, 4, 5]) { XCTFail(fail.description) }
//        nested: if let fail = roundTrip2([[[[[[1]]], [[[2]]]]]]) { XCTFail(fail.description) }
//
//        // dictionary
//        single: if let fail = roundTrip2([1: 1]) { XCTFail(fail.description) }
//        multiple: if let fail = roundTrip2(asDictionary([1, 2, 3, 4, 5])) { XCTFail(fail.description) }
//        nested: if let fail = roundTrip2(asDictionary([[[[[[1]]], [[[2]]]]]])) { XCTFail(fail.description) }
//
//        // mixed array and dictionary
//        arrayFirst: if let fail = roundTrip2([[1: 1]]) { XCTFail(fail.description) }
//        dictionaryFirst: if let fail = roundTrip2([1: [1]]) { XCTFail(fail.description) }
//        arrayDictArray: if let fail = roundTrip2([[1: [1: 1]]]) { XCTFail(fail.description) }
//        dictArrayDict: if let fail = roundTrip2([1: [[1: 1]]]) { XCTFail(fail.description) }
//
//        // objects
//        if let fail = roundTrip2([Objects.Single()]) { XCTFail(fail.description) }
//        if let fail = roundTrip2(Objects.Keyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip2(Objects.Unkeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip2(Objects.NestedKeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip2(Objects.NestedUnkeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip2(Objects.SubKeyed()) { XCTFail(fail.description) }
//        if let fail = roundTrip2(Objects.SubUnkeyed()) { XCTFail(fail.description) }
//    }
//
//    func testPath() {
//
//        let v = Float.infinity
//
//        // array
//        single: if let fail = path2([v]) { XCTFail(fail.description) }
//        nested: if let fail = path2([[[[[[1 as Float]]], [[[v]]]]]]) { XCTFail(fail.description) }
//
//        // dictionary
//        single: if let fail = path2(["1": v]) { XCTFail(fail.description) }
//        nested: if let fail = path2(asStringDictionary([[[[[[v]]], [[[1 as Float]]]]]])) { XCTFail(fail.description) }
//
//        // mixed array and dictionary
//        arrayFirst: if let fail = path2([["1": v]]) { XCTFail(fail.description) }
//        dictionaryFirst: if let fail = path2(["1": [v]]) { XCTFail(fail.description) }
//        arrayDictArray: if let fail = path2([["1": ["1": v]]]) { XCTFail(fail.description) }
//        dictArrayDict: if let fail = path2(["1": [["1": v]]]) { XCTFail(fail.description) }
//
//        // objects
//        if let fail = path2([Objects.Throwing.Single()]) { XCTFail(fail.description) } // JSONSerialization cannot handle single top-level objects
//        if let fail = path2(Objects.Throwing.Keyed()) { XCTFail(fail.description) }
//        if let fail = path2(Objects.Throwing.Unkeyed()) { XCTFail(fail.description) }
//        if let fail = path2(Objects.Throwing.NestedKeyed()) { XCTFail(fail.description) }
//        if let fail = path2(Objects.Throwing.NestedUnkeyed()) { XCTFail(fail.description) }
//        if let fail = path2(Objects.Throwing.SubKeyed()) { XCTFail(fail.description) }
//        if let fail = path2(Objects.Throwing.SubUnkeyed()) { XCTFail(fail.description) }
//    }

//    // MARK: round trip
//
//    enum RoundTripFail: CustomStringConvertible {
//
//        case valueToAny(Error)
//        case valueToData(Error)
//        case valueFromData(Error)
//        case valueFromAny(Error)
//
//        private var error: Error {
//            switch self {
//            case .valueToAny(let error): return error
//            case .valueToData(let error): return error
//            case .valueFromData(let error): return error
//            case .valueFromAny(let error): return error
//            }
//        }
//
//        private var name: String {
//
//            switch self {
//            case .valueToAny(_): return "value to Any"
//            case .valueToData(_): return "value to Data"
//            case .valueFromData(_): return "value from Data"
//            case .valueFromAny(_): return "value from Any"
//            }
//        }
//
//        var description: String {
//            return "\(self.name): \(self.error)"
//        }
//    }
//
//    enum RTError<T>: Error {
//        case invalidRepresentation(forOriginal: T, value: Any)
//        case unequal(T, T)
//    }
//
//    typealias TypeId = ObjectIdentifier
//
//    var isValidRepresentation: [TypeId: (Any)->Bool] = [
//        TypeId(NSNull.self): { $0 is NSNull},
//        TypeId(Bool  .self): { $0 is Bool  },
//        TypeId(Int   .self): { $0 is Int   },
//        TypeId(Int8  .self): { $0 is Int8  },
//        TypeId(Int16 .self): { $0 is Int16 },
//        TypeId(Int32 .self): { $0 is Int32 },
//        TypeId(Int64 .self): { $0 is Int64 },
//        TypeId(UInt  .self): { $0 is Int   },
//        TypeId(UInt8 .self): { $0 is Int8  },
//        TypeId(UInt16.self): { $0 is Int16 },
//        TypeId(UInt32.self): { $0 is Int32 },
//        TypeId(UInt64.self): { $0 is Int64 },
//        TypeId(Float .self): { $0 is Float },
//        TypeId(Double.self): { $0 is Double},
//        TypeId(String.self): { $0 is String}
//    ]
//
//    func isValidRepresentation(int    original: Int   , _ value: Int   ) -> Bool { return value == original }
//    func isValidRepresentation(int8   original: Int8  , _ value: Int8  ) -> Bool { return value == original }
//    func isValidRepresentation(int16  original: Int16 , _ value: Int16 ) -> Bool { return value == original }
//    func isValidRepresentation(int32  original: Int32 , _ value: Int32 ) -> Bool { return value == original }
//    func isValidRepresentation(int64  original: Int64 , _ value: Int64 ) -> Bool { return value == original }
//    func isValidRepresentation(uint   original: UInt  , _ value: UInt  ) -> Bool { return value == original }
//    func isValidRepresentation(uint8  original: UInt8 , _ value: UInt8 ) -> Bool { return value == original }
//    func isValidRepresentation(uint16 original: UInt16, _ value: UInt16) -> Bool { return value == original }
//    func isValidRepresentation(uint32 original: UInt32, _ value: UInt32) -> Bool { return value == original }
//    func isValidRepresentation(uint64 original: UInt64, _ value: UInt64) -> Bool { return value == original }
//    func isValidRepresentation(float  original: Float , _ value: Float ) -> Bool { return value == original }
//    func isValidRepresentation(double original: Double, _ value: Double) -> Bool { return value == original }
//    func isValidRepresentation(string original: String, _ value: String) -> Bool { return value == original }
//
//
//    func Equatable<T: Equatable>(_: T.Type) {
//
//    }
//
//    func isValidRepresentation<T: Codable>(for original: T, _ value: Any) {
//
//        Equatable(Array<Any>.self)
//    }
//
//    func roundTrip<T: Codable>(_ start: T, isEqual: (T, T)->Bool) -> RoundTripFail? {
    //
    //        let value: Any
    //
    //        // value to Any
    //        do {
    //
    //            value = try self.encoder.encode(value: start)
    //
    //            guard let isValidClosure = isValidRepresentation[TypeId(T.self)] else {
    //                fatalError("no isValidRepresentation for \(T.self)")
    //            }
    //
    //            guard isValidClosure(value) else  {
    //                return RoundTripFail.valueToAny(RTError.invalidRepresentation(forOriginal: start, value: value))
    //            }
    //
    //        } catch {
    //
    //            return RoundTripFail.valueToAny(error)
    //
    //        }
    //
    //        // value to Data
    //
    //        let data: Data
    //
    //        do {
    //
    //            data = try self.encoder.encode(data: start)
    //
    //        } catch {
    //
    //            return RoundTripFail.valueToData(error)
    //
    //        }
    //
    //        // value from Data
    //
    //        do {
    //
    //            let result = try self.decoder.decode(T.self, from: data)
    //
    //            guard isEqual(start, result) else {
    //                return RoundTripFail.valueFromData(RTError.unequal(start, result))
    //            }
    //
    //        } catch {
    //
    //            return RoundTripFail.valueFromData(error)
    //        }
    //
    //        // value from Any
    //
    //        do {
    //
    //            let result = try self.decoder.decode(T.self, fromValue: value)
    //
    //            guard isEqual(start, result) else {
    //                return RoundTripFail.valueFromAny(RTError.unequal(start, result))
    //            }
    //
    //        } catch {
    //
    //            return RoundTripFail.valueFromAny(error)
    //
    //        }
    //
    //        return nil
//    }
//
//    func roundTrip<T: Codable & Equatable>(_ start: T) -> RoundTripFail? {
//
//        return roundTrip(start, isEqual: { $0 == $1 })
//    }
//
//    func roundTrip2<T: Codable>(_ value1: T) -> RoundTripFail? {
//
//        let value: Any
//
//        // value to Any
//        do {
//
//            value = try self.encoder2.encode(value: value1)
//
//        } catch {
//
//            return RoundTripFail.valueToAny(error)
//
//        }
//
//        // value to Data
//
//        let data: Data
//
//        do {
//
//            data = try self.encoder2.encode(data: value1)
//
//        } catch {
//
//            return RoundTripFail.valueToData(error)
//
//        }
//
//        // value from Data
//
//        do {
//
//            let value2 = try self.decoder2.decode(T.self, from: data)
//
//            guard same(value1, value2) else {
//                return RoundTripFail.valueFromData(RTError.unequal(value1, value2))
//            }
//
//        } catch {
//
//            return RoundTripFail.valueFromData(error)
//        }
//
//        // value from Any
//
//        do {
//
//            let value2 = try self.decoder2.decode(T.self, fromValue: value)
//
//            guard same(value1, value2) else {
//                return RoundTripFail.valueFromAny(RTError.unequal(value1, value2))
//            }
//
//        } catch {
//
//            return RoundTripFail.valueFromAny(error)
//
//        }
//
//        return nil
//    }
//
//    func asDictionary<U>(_ array: [U]) -> [Int: U] {
//        return array.enumerated().reduce(into: [Int: U](), { (result, next) in
//            result[next.offset] = next.element
//        })
//    }
//
//    func asStringDictionary<U>(_ array: [U]) -> [String: U] {
//        return array.enumerated().reduce(into: [String: U](), { (result, next) in
//            result[next.offset.description] = next.element
//        })
//    }
//
//    // MARK: Path
//
//    indirect enum PathFail: CustomStringConvertible {
//        // encoding
//        case jsonEncoderDidNotThrow(result: Any)
//        case encoderDidNotThrow(result: Any)
//        case notEncodingError(Error)
//        case encoderDifferentPaths(expected: EncodingError.Context, returned: EncodingError.Context)
//        case encoderMismatchValues(expected: EncodingError, returned: EncodingError)
//
//        // decoding
//        case jsonDecoderDidNotThrow(result: Any)
//        case decoderDidNotThrow(result: Any)
//        case notDecodingError(Error)
//        case decoderDifferentPaths(expected: DecodingError.Context, returned: DecodingError.Context)
//        case mismatchErrors(expected: DecodingError, returned: DecodingError)
//        case mismatchCodingKeyNotFound(expected: DecodingError, returned: DecodingError)
//        case mismatchType(expected: DecodingError, returned: DecodingError)
//
//        case somethingFailed(encode: PathFail?, decode: PathFail?)
//
//        var description: String {
//
//            func description(for value: Any) -> String {
//                return "\(type(of: value)) :: \(value)"
//            }
//
//            func add(expected: Any, received: Any) -> String {
//                return ", expected: \(expected) received: \(received)"
//            }
//
//            func add(context1: Any, context2: Any) -> String {
//                return ", context1: \(context1), context2: \(context2)"
//            }
//
//            switch self {
//
//            case .jsonEncoderDidNotThrow(result: let result):
//                return "JSONEncoder did not throw, result: " + description(for: result)
//
//            case .encoderDidNotThrow(result: let result):
//                return "did not throw, result: " + description(for: result)
//
//            case .notEncodingError(let error):
//                return "not encoding error: " + description(for: error)
//
//            case .encoderDifferentPaths(expected: let context1, returned: let context2):
//                return "encoder different paths" + add(expected: context1.codingPath.count, received: context2.codingPath.count) + add(context1: context1, context2: context2)
//
//            case .encoderMismatchValues(expected: let error1, returned: let error2):
//                guard case .invalidValue(let value1, let context1) = error1 else { fatalError() }
//                guard case .invalidValue(let value2, let context2) = error2 else { fatalError() }
//                return "encoder different values" + add(expected: value1, received: value2) + add(context1: context1, context2: context2)
//
//            case .jsonDecoderDidNotThrow(result: let result):
//                return "JSONDecoder did not throw, result: " + description(for: result)
//
//            case .decoderDidNotThrow(result: let result):
//                return "did not throw, result: " + description(for: result)
//
//            case .notDecodingError(let error):
//                return "not decoding error: " + description(for: error)
//
//            case .decoderDifferentPaths(expected: let context1, returned: let context2):
//                return "different paths" + add(expected: context1.codingPath.count, received: context2.codingPath.count) + add(context1: context1, context2: context2)
//
//            case .mismatchErrors(expected: let error1, returned: let error2):
//                return "mismatch errors" + add(expected: error1, received: error2)
//
//            case .mismatchCodingKeyNotFound(expected: let error1, returned: let error2):
//                guard case .keyNotFound(let key1, let context1) = error1 else { fatalError() }
//                guard case .keyNotFound(let key2, let context2) = error2 else { fatalError() }
//
//                return "mismatch key not found" + add(expected: description(for: key1), received: description(for: key2)) + add(context1: context1, context2: context2)
//
//            case .mismatchType(expected: let error1, returned: let error2):
//
//                if case .typeMismatch(let type1, let context1) = error1 {
//                    guard case .typeMismatch(let type2, let context2) = error2 else { fatalError() }
//
//                    return "mismatch types" + add(expected: type1, received: type2) + add(context1: context1, context2: context2)
//
//                } else {
//
//                    guard case .valueNotFound(let type1, let context1) = error1 else { fatalError() }
//                    guard case .valueNotFound(let type2, let context2) = error2 else { fatalError() }
//
//                    return "value not found: mismatch types" + add(expected: type1, received: type2) + add(context1: context1, context2: context2)
//
//                }
//
//            case .somethingFailed(encode: let encodeReason, decode: let decodeReason):
//
//                switch (encodeReason, decodeReason) {
//                case (.some(let encodeReason), .some(let decodeReason)):
//                    return "encodeError: \(encodeReason), decodeError: \(decodeReason)"
//
//                case (.some(let encodeReason), .none):
//                    return "encodeError: \(encodeReason)"
//
//                case (.none, .some(let decodeReason)):
//                    return "decodeError: \(decodeReason)"
//
//                case (.none, .none):
//                    fatalError()
//                }
//
//            }
//        }
//    }
//
//    func checkContexts(expected context1: EncodingError.Context, returned context2: EncodingError.Context) -> PathFail? {
//
//        func failed() -> PathFail {
//            return PathFail.encoderDifferentPaths(expected: context1, returned: context2)
//        }
//
//        if context1.codingPath.count != context2.codingPath.count {
//            return failed()
//        }
//
//        for (key1, key2) in zip(context1.codingPath, context2.codingPath) {
//
//            if key1.stringValue != key2.stringValue {
//                print("key1: \(key1), key2: \(key2)")
//                return failed()
//            }
//
//            // cannot get _JSONKey
//            if type(of: key2) is String.Type {
//                continue
//            }
//
//            if type(of: key1) != type(of: key2) {
//                return failed()
//            }
//        }
//
//        if context1.debugDescription != context2.debugDescription {
//            print("\(context1.debugDescription) || \(context2.debugDescription)")
//        }
//
//        if context1.underlyingError != nil {
//            print("context1 error: \(context1.underlyingError!)")
//        }
//
//        if context2.underlyingError != nil {
//            print("context2 error: \(context2.underlyingError!)")
//        }
//
//        return nil
//    }
//
//    func encodePath<T: Encodable>(_ value: T, with encoder: TopLevelEncoder) -> PathFail? {
//
//        let jsonError: EncodingError
//
//        do {
//            let result = try JSONEncoder().encode(value)
//
//            return PathFail.jsonEncoderDidNotThrow(result: result)
//
//        } catch let error as EncodingError {
//
//            jsonError = error
//
//        } catch {
//
//            fatalError("jsonEncoder threw wrong type of error: \(type(of: error)) :: \(error)")
//        }
//
//
//        do {
//
//            let result = try encoder.encode(data: value)
//
//            return PathFail.encoderDidNotThrow(result: result)
//
//        } catch let error as EncodingError {
//
//            switch error {
//            case .invalidValue(let value2, let context2):
//                guard case .invalidValue(let value1, let context1) = jsonError else {fatalError()}
//
//                guard same(value1, value2) else {
//                    return PathFail.encoderMismatchValues(expected: jsonError, returned: error)
//                }
//
//                return checkContexts(expected: context1, returned: context2)
//            }
//        } catch {
//            return PathFail.notEncodingError(error)
//        }
//    }
//
//    func checkContexts(expected context1: DecodingError.Context, returned context2: DecodingError.Context) -> PathFail? {
//
//        func failed() -> PathFail {
//            return PathFail.decoderDifferentPaths(expected: context1, returned: context2)
//        }
//
//        if context1.codingPath.count != context2.codingPath.count {
//            return failed()
//        }
//
//        for (key1, key2) in zip(context1.codingPath, context2.codingPath) {
//
//            if key1.stringValue != key2.stringValue {
//                return failed()
//            }
//
//            // cannot get _JSONKey
//            if type(of: key2) is String.Type {
//                continue
//            }
//
//            if type(of: key1) != type(of: key2) {
//                return failed()
//            }
//        }
//
//        if context1.debugDescription != context2.debugDescription {
//            print("\(context1.debugDescription) || \(context2.debugDescription)")
//        }
//
//        if context1.underlyingError != nil {
//            print("context1 error: \(context1.underlyingError!)")
//        }
//
//        if context2.underlyingError != nil {
//            print("context2 error: \(context2.underlyingError!)")
//        }
//
//        return nil
//    }
//
//    func decodePath<T: Decodable>(_ value: T, with decoder: TopLevelDecoder) -> PathFail? {
//
//        let encoded = artificialEncode(value)
//
//        assert(JSONSerialization.isValidJSONObject(encoded), "\(type(of: value)) :: \(value) invalid json object: \(type(of: encoded)) :: \(encoded)")
//
//        let data = try! JSONSerialization.data(withJSONObject: artificialEncode(value))
//
//        let jsonDecoderError: DecodingError
//
//        do {
//
//            let result = try JSONDecoder().decode(T.self, from: data)
//
//            return PathFail.jsonDecoderDidNotThrow(result: result)
//
//        } catch let error as DecodingError {
//
//            jsonDecoderError = error
//
//        } catch {
//
//            fatalError("did not test correctly")
//        }
//
//        do {
//
//            let result = try decoder.decode(T.self, from: data)
//
//            return PathFail.decoderDidNotThrow(result: result)
//
//        } catch let error as DecodingError {
//
//            switch jsonDecoderError {
//            case .dataCorrupted(let context1):
//                guard case .dataCorrupted(let context2) = error else {
//                    return PathFail.mismatchErrors(expected: jsonDecoderError, returned: error)
//                }
//
//                return checkContexts(expected: context1, returned: context2)
//
//            case .keyNotFound(let key1, let context1):
//
//                guard case .keyNotFound(let key2, let context2) = error else {
//                    return PathFail.mismatchErrors(expected: jsonDecoderError, returned: error)
//                }
//
//                guard key1.stringValue == key2.stringValue else {
//                    return PathFail.mismatchCodingKeyNotFound(expected: jsonDecoderError, returned: error)
//                }
//
//                return checkContexts(expected: context1, returned: context2)
//
//            case .typeMismatch(let type1, let context1):
//
//                guard case .typeMismatch(let type2, let context2) = error else {
//                    return PathFail.mismatchErrors(expected: jsonDecoderError, returned: error)
//                }
//
//                if type1 != type2 {
//
//                    if type2 as? DecoderUnkeyedContainerContainer.Type != nil && type1 as? Array<Any>.Type != nil {
//
//                    } else if type2 as? DecoderKeyedContainerContainer.Type != nil && type1 as? Dictionary<String, Any>.Type != nil {
//
//                    } else {
//                        return PathFail.mismatchType(expected: jsonDecoderError, returned: error)
//                    }
//                }
//
//                return checkContexts(expected: context1, returned: context2)
//
//            case .valueNotFound(let type1, let context1):
//
//                guard case .typeMismatch(let type2, let context2) = error else {
//                    return PathFail.mismatchErrors(expected: jsonDecoderError, returned: error)
//                }
//
//                if type1 != type2 {
//
//                    if type2 as? DecoderUnkeyedContainerContainer.Type != nil && type1 as? Array<Any>.Type != nil {
//
//                    } else if type2 as? DecoderKeyedContainerContainer.Type != nil && type1 as? Dictionary<String, Any>.Type != nil {
//
//                    } else {
//                        return PathFail.mismatchType(expected: jsonDecoderError, returned: error)
//                    }
//                }
//
//                guard type1 == type2 else {
//                    return PathFail.mismatchType(expected: jsonDecoderError, returned: error)
//                }
//
//                return checkContexts(expected: context1, returned: context2)
//            }
//
//        } catch {
//
//            return PathFail.notDecodingError(error)
//        }
//    }
//
//    func path<T: Codable>(_ value: T) -> PathFail? {
//
//        let encodeResult = encodePath(value, with: self.encoder)
//        let decodeResult = decodePath(value, with: self.decoder)
//
//        if encodeResult != nil || decodeResult != nil {
//            return PathFail.somethingFailed(encode: encodeResult, decode: decodeResult)
//        } else {
//            return nil
//        }
//    }
//
//    func path2<T: Codable>(_ value: T) -> PathFail? {
//
//        let encodeResult = encodePath(value, with: self.encoder2)
//        let decodeResult = decodePath(value, with: self.decoder2)
//
//        if encodeResult != nil || decodeResult != nil {
//            return PathFail.somethingFailed(encode: encodeResult, decode: decodeResult)
//        } else {
//            return nil
//        }
//    }
}
