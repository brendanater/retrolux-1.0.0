//
//  File1.swift
//  Retrolux
//
//  Created by Brendan Henderson on 9/28/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol CoderTestCase {
    
    func newEncoder() -> TopLevelEncoder
    func newDecoder() -> TopLevelDecoder
}

public extension CoderTestCase {
    
    typealias Objects = CoderTesting.Objects
    
    func testingValues<T: SignedInteger & FixedWidthInteger & Codable>(for: T.Type) -> Objects.CEArray<T> {
        return [
            .max,
            .min,
            0,
            34,
            110,
            -13,
            -72
        ]
    }
    
    func testingValues<T: UnsignedInteger & FixedWidthInteger & Codable>(for: T.Type) -> Objects.CEArray<T> {
        return [
            .max,
            .min,
            0,
            34,
            110,
            220
        ]
    }

    func testingValues<T: FloatingPoint & Codable>(for: T.Type) -> Objects.CEArray<T> {

        let type = "\(T.self)"

        var result: Objects.CEArray<T> = []

        func add(_ value: T) {
            result.append(value)
            result.append(-value)
        }

        add(.greatestFiniteMagnitude)
        add(.infinity)
        add(.leastNonzeroMagnitude)
        add(.leastNormalMagnitude)
        add(.nan)
        add(.pi)
        add(.signalingNaN)
        add(.ulpOfOne)
        add(0)
        add(123234)

        return result
    }
    
    var intValues   : Objects.CEArray<Int   > { return self.testingValues(for: Int   .self) }
    var int8Values  : Objects.CEArray<Int8  > { return self.testingValues(for: Int8  .self) }
    var int16Values : Objects.CEArray<Int16 > { return self.testingValues(for: Int16 .self) }
    var int32Values : Objects.CEArray<Int32 > { return self.testingValues(for: Int32 .self) }
    var int64Values : Objects.CEArray<Int64 > { return self.testingValues(for: Int64 .self) }
    var uintValues  : Objects.CEArray<UInt  > { return self.testingValues(for: UInt  .self) }
    var uint8Values : Objects.CEArray<UInt8 > { return self.testingValues(for: UInt8 .self) }
    var uint16Values: Objects.CEArray<UInt16> { return self.testingValues(for: UInt16.self) }
    var uint32Values: Objects.CEArray<UInt32> { return self.testingValues(for: UInt32.self) }
    var uint64Values: Objects.CEArray<UInt64> { return self.testingValues(for: UInt64.self) }
    var floatValues : Objects.CEArray<Float > { return self.testingValues(for: Float .self) }
    var doubleValues: Objects.CEArray<Double> { return self.testingValues(for: Double.self) }
//
////    func path<T: Codable>(_ values: [T]) -> CustomStringConvertible? {
////
////        var fails = Testing.Coding.Fails()
////
////        for value in values {
////            if let fail = path(value) {
////                fails.add(fail)
////            }
////        }
////
////        return fails
////    }
//
//    func pathTest<T: Codable>(topLevelAndNested v: T) -> CustomStringConvertible? {
//
//        typealias O = Objects<String, Int, T>
//
//        var fails: [String] = []
//
//        func add<T: Codable>(_ value: T) {
//
//            if let fail = pathTest(value) {
//                fails.append(fail.description)
//            }
//        }
//
//        add(v)
//
//        add([v])
//        add([[[[v]]]])
//
//        add(["1": v])
//        add(["1": ["1": v]])
//        add(["1": ["1": ["1": v]]])
//
//        add(["1": [["1": v]]])
//
//        add([["1": v]])
//        add(["1": [v]])
//        add([["1": ["1": v]]])
//        add(["1": [["1": v]]])
//
//        add(O.Single(value1: "test", value2: Int.max, value3: v))
//        add(O.Keyed(value1: "test", value2: Int.min, value3: v))
//        add(O.Unkeyed(value1: "", value2: -0, value3: v))
//        // crashes. internal error
//        //        add(pathTest: O.NestedKeyed(value1: "asdasudhg-=0", value2: 13208, value3: .init()))
//        //        add(pathTest: O.NestedUnkeyed(value1: "asdpa.1v4", value2: -198714, value3: .init()))
//        add(O.SubKeyed(value1: "asdpa.1v4", value2: -198714, value3: v))
//        add(O.SubSubKeyed(value1: "asdpa.1v4", value2: -198714, value3: v))
//        add(O.SubUnkeyed(value1: "asdpa.1v4", value2: -198714, value3: v))
//        add(O.SubSubUnkeyed(value1: "asdpa.1v4", value2: -198714, value3: v))
//
//        if fails.isEmpty {
//            return nil
//        } else {
//            return "\n\n\(fails.count) fails for \(T.self): \(v)\n" + fails.joined(separator: "\n\n")
//        }
//    }
//
//    typealias Fails = Testing.Coding.Fails
//
//    func startLoggingFails(forTest description: String) -> Fails {
//
//        return Fails.init(forTest: description)
//    }
//
//    public func basicPathTest() -> CustomStringConvertible? {
//
//        var fails = self.startLoggingFails(forTest: "basicPathTests")
//
//        let v = Testing.Coding.TestObject()
//
//        func add<T: Codable>(_ value: T) {
//
//            fails.add(self.pathTest(topLevelAndNested: value))
//        }
//
//        add(v)
//
//        return fails.result
//    }
//
//    public func pathTest<T: Codable>(_ value: T) -> CustomStringConvertible? {
//
//        let expectedPath = self.expectedPath(for: value)
//
//        var encoder = self.newEncoder()
//
//        do {
//
//            _ = try encoder.encode(value: value)
//
//            return Testing.Coding.Path.Fail.encode(value, .didNotThrow)
//
//        } catch let EncodingError.invalidValue(_, context) {
//
//            if let incorrectPath = self.equalPaths(expected: context.codingPath, received: expectedPath) {
//
//                return Testing.Coding.Path.Fail.encode(value, .incorrectPath(incorrectPath, codingPath: context.codingPath, expected: expectedPath))
//            }
//
//        } catch {
//
//            fatalError("\(type(of: encoder)) did not throw an EncodingError while encoding \(type(of: value)): \(value), error: \(error)")
//        }
//
//        let decoder = self.newDecoder()
//
//        encoder.userInfo.testingThrow = false
//
//        let _value: Any
//
//        do {
//            _value = try encoder.encode(value: value)
//
//        } catch let error as EncodingError {
//
//            return Testing.Coding.Path.Fail.encode(value, .failedToEncodeForDecoder(error: error))
//
//        } catch {
//
//            fatalError("\(type(of: encoder)) did not throw an EncodingError while encoding for decoder \(type(of: value)): \(value), error: \(error)")
//        }
//
//        do {
//
//            _ = try decoder.decode(T.self, fromValue: _value)
//
//            return Testing.Coding.Path.Fail.decode(value, .didNotThrow)
//
//        } catch let error as DecodingError {
//
//            if let incorrectPath = self.equalPaths(expected: expectedPath, received: error.context.codingPath) {
//                return Testing.Coding.Path.Fail.decode(value, .incorrectPath(incorrectPath, codingPath: error.context.codingPath, expected: expectedPath))
//            }
//
//        } catch {
//
//            fatalError("\(type(of: encoder)) did not throw an EncodingError while decoding \(type(of: value)): \(value), error: \(error)")
//        }
//
//        return nil
//    }
    
    /// tests a value that should be able to be encoded and then decoded from the result
    func roundTrip<T: Codable & Equatable>(_ value: T) -> CustomStringConvertible? {
        
        let _value: Any
        
        do {
            _value = try self.newEncoder().encode(value: value)
        } catch {
            return "failed encode with error: \(error)"
        }
        
        let data: Data
        
        do {
            data = try self.newEncoder().encode(value)
        } catch {
            return "failed encode to data with error: \(error)"
        }
        
        do {
            let result = try self.newDecoder().decode(T.self, fromValue: _value)
            
            guard result == value else {
                return "failed decode. result: \(result) not equal to value: \(value)"
            }
            
        } catch {
            return "failed decode with error: \(error)"
        }
        
        do {
            let result = try self.newDecoder().decode(T.self, from: data)
            
            guard result == value else {
                return "failed decode from data. result: \(result) not equal to value: \(value)"
            }
            
        } catch {
            return "failed decode from data with error: \(error)"
        }
        
        return nil
    }
    
    /// splits the character sets into manageable strings and returns the first roundTrip fail in a custom description or nil
    func roundTripAsStrings<T: Codable & Equatable>(characterSets: [CharacterSet], removeCharacters: String, compatibleContainer: (String)->T) -> CustomStringConvertible? {
        
        for characterSet in characterSets {
            
            var subCharacterSet = characterSet

            subCharacterSet.remove(charactersIn: removeCharacters)

            let allCharacters = subCharacterSet.allCharacters()

            var counter = 0

            while let nextSequence = allCharacters.slice(at: counter, count: 50) {
                counter += 1

                let currentEncodingString = String(nextSequence)
                
                let value = compatibleContainer(currentEncodingString)
                
                if let fail = self.roundTrip(value) {
                    
                    let currentEncodingString = currentEncodingString.characters.map { String($0) }.joined(separator: " ")
                    
                    let removedCharacters = (removeCharacters.isEmpty ? "" : " with removed characters: \(removeCharacters)")
                    
                    return "\(characterSet)\(removedCharacters) failed roundTrip in container type: \(type(of: value)) (with reason: \(fail)), currently encoding (without spaces): \(currentEncodingString)"
                }
            }
        }
        
        return nil
    }
    
    
    
//    typealias P = CoderTesting.Parameter
//    
//    func encodePathTest<Expected: Encodable & Equatable, E: Encodable>(for expected: Expected, in encodable: E) -> CustomStringConvertible? {
//        
//        let here = "\(type(of: self)).\(#function)"
//        let parameters = [P("for expected", expected),
//                          P("in encodable", encodable)]
//        
//        let expectedPath = CoderTesting.expectedEncodePath(for: expected, in: encodable)
//        
//        let encoder = self.newEncoder()
//        
//        do {
//            
//            _ = try encoder.encode(value: encodable)
//            
//            return CoderTesting.fail(
//                at: here,
//                with: parameters,
//                failedWithReason:
//                "\(type(of: encoder)) did not throw"
//            )
//            
//        } catch let error as EncodingError {
//            
//            if let fail = CoderTesting.guardEqual(expected: expectedPath, actual: error.context.codingPath) {
//                
//                return CoderTesting.fail(
//                    at: here,
//                    with: parameters,
//                    failedWithReason: fail
//                )
//                
//            } else {
//                return nil
//            }
//            
//        } catch {
//            return CoderTesting.fail(
//                at: here,
//                with: parameters,
//                failedWithReason: "\(type(of: encoder)) threw a non-EncodingError: \(error)"
//            )
//        }
//    }
//    
//    func decodePathTest<Expected: Codable & Equatable, C: Codable, Encoded: Equatable>(for expected: Expected, in codable: C, whereEncoded encoded: Encoded) -> CustomStringConvertible? {
//        
//        let here = "\(type(of: self)).\(#function)"
//        let parameters = [
//            P.init("for expected", expected),
//            P.init("in codable", codable),
//            P.init("whereEncoded", encoded)
//        ]
//        
//        let expectedPath = CoderTesting.expectedDecodePath(for: expected, in: codable)
//        
//        let decoder = self.newDecoder()
//        
//        do {
//            _ = try decoder.decode(type(of: codable), fromValue: encoded)
//            
//            return CoderTesting.fail(
//                at: here,
//                with: parameters,
//                failedWithReason: "\(type(of: decoder)) did not throw"
//            )
//            
//        } catch let error as DecodingError {
//            
//            if let fail = CoderTesting.guardEqual(expected: expectedPath, actual: error.context.codingPath) {
//                return CoderTesting.fail(
//                    at: here,
//                    with: parameters,
//                    failedWithReason: fail.description
//                )
//            } else {
//                return nil
//            }
//            
//        } catch {
//            return CoderTesting.fail(
//                at: here,
//                with: parameters,
//                failedWithReason: "\(type(of: decoder)) threw a non-DecodingError: \(error)"
//            )
//        }
//    }
}

// MARK: CoderTesting

// a struct to hold various Testing values
public struct CoderTesting {
    
    public static func guardEqual(expected: [CodingKey], actual: [CodingKey]) -> CustomStringConvertible? {
        
        guard expected.count == actual.count else {
            return """
            different coding path counts:
            expected: \(expected.count) from: \(expected)
            actual: \(actual.count) from: \(actual)
            """
        }
        
        for (expectedKeyAtIndex, key2) in zip(expected.enumerated(), actual) {
            
            let key1 = expectedKeyAtIndex.element
            
            guard key1.isEqual(to: key2) else {
                
                func description(for key: CodingKey) -> String {
                    return "\(type(of: key))(stringValue: \(key.stringValue), intValue: \(key.intValue?.description ?? "nil"))"
                }
                
                func description(forPath path: [CodingKey]) -> [String] {
                    return path.map { description(for: $0) }
                }
                
                let key1 = description(for: key1)
                let key2 = description(for: key2)
                let expected = description(forPath: expected)
                let actual = description(forPath: actual)
                
                return """
                different coding keys at index \(expectedKeyAtIndex.offset):
                expected: \(key1) from: \(expected)
                actual: \(key2) from: \(actual)
                """
            }
        }
        
        return nil
    }
    
    public static func fail(at place: CustomStringConvertible, with parameters: [Parameter] = [], failedWithReason failReason: CustomStringConvertible) -> CustomStringConvertible {
        
        let parameterDescription = (parameters.isEmpty ? "" : "\nwith parameters:\n\(parameters.map { $0.description }.joined(separator: "\n"))")
        
        return """
        at: \(place.description)\(parameterDescription)
        failedWithReason:
        \(failReason)
        """
    }
    
    public struct Parameter {
        var description: String
        init(_ parameterDescription: String, _ value: Any) {
            self.description = parameterDescription + ": \(type(of: value)): \(value)"
        }
        init(_ parameterDescription: String, _ type: Any.Type) {
            self.description = parameterDescription + ": \(type)"
        }
    }
    
    // MARK: CodingStats
    
    class EncoderSharedOptions {
        var willCrashIfJSONEncoder: Bool = false
    }
    
    public enum EncodedType {
        case single
        case unkeyed
        case keyed
    }
    
    class VoidEncoderOptions<Expected> {
        
        var expected: Expected
        var throwAtExpected: Bool = true
        
        init(_ expected: Expected) {
            self.expected = expected
        }
        
        var topLevelType: EncodedType = .single
        
        func checkTopLevel(_ newType: EncodedType) {
            if self.topLevelType == .single && newType != .single {
                self.topLevelType = newType
            }
        }
        
        lazy var willCrashIfJSONEncoder: Bool = false
    }
    
    /**
     Encodes the encodable looking for equal expected and throwing at that path
     crashes if encodable does not encode the expected value
     rethrows unknown errors
     */
    public static func encodeStats<Expected: Encodable & Equatable, E: Encodable>(for expected: Expected, in encodable: E, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> (encodePath: [CodingKey], willCrashIfJSONEncoder: Bool, topLevelType: EncodedType) {
        
        let encoder = VoidEncoder(options: VoidEncoderOptions(expected), userInfo: userInfo)
        
        do {
            _ = try encoder.start(with: encodable)
            
            fatalError("\(type(of: encodable)) did not encode an equal \(type(of: expected)): \(expected) for path.")
            
        } catch let error as EncodingError {
            
            if error.context.debugDescription == sharedThrowDescription {
                
                return (error.context.codingPath, encoder.options.willCrashIfJSONEncoder, encoder.options.topLevelType)
            } else {
                throw error
            }
        }
    }
    
    /// throws at first decode of Expected.Type.  Can only decode 2 values from unkeyed container.  There are 2 keys in keyed container, but unlimited values
    public static func decodeStats<Expected: Decodable, D: Decodable>(for: Expected.Type, in: D.Type, userInfo: [CodingUserInfoKey: Any]) throws -> (decodePath: [CodingKey], Void) {
        
        let decoder = VoidDecoder<Expected>(userInfo: userInfo)
        
        do {
            _ = try decoder.start(with: ()) as D
            fatalError("\(D.self) did not decode type: \(Expected.self)")
            
        } catch let error as DecodingError {
            
            if error.context.debugDescription == sharedThrowDescription {
                return (error.context.codingPath, ())
            } else {
                throw error
            }
        }
    }
    
    /// because the value can also be encoded,
    public static func allStats() {
        
        
        
        
    }
    
    
//
//    private static func _encode<Expected: Encodable & Equatable, E: Encodable>(for expected: Expected, in encodable: E, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> (stats: EncodeStats, encoded: Any) {
//            
//        let (encodePath, willCrash) = try self.encodePath(for: expected, in: encodable, userInfo: userInfo)
//        
//        let encoded = try VoidEncoder(options: (expected: expected, shared: EncoderSharedOptions(), throw: false), userInfo: userInfo).start(with: encodable)
//        
//        return (
//            (
//                encodePath,
//                willCrash,
//                { () -> EncodedType in
//                    
//                    switch encoded {
//                    case is NSArray: return .unkeyed
//                    case is NSDictionary: return .keyed
//                    default: return .single
//                    }
//                }()
//            ),
//            encoded
//        )
//    }
//    
//    public typealias EncodeStats = (encodePath: [CodingKey], willCrashIfJSONEncoder: Bool, topLevelType: EncodedType)
//    
//    public static func encodeStats<Expected: Encodable & Equatable, E: Encodable>(for expected: Expected, in encodable: E, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> EncodeStats {
//        
//        return try self._encode(for: expected, in: encodable, userInfo: userInfo).stats
//    }
//    
//    private static var _decodingTestDebugDescription = "threw at codingPath"
//    
//    public typealias AllStatsResult = (encodePath: [CodingKey], decodePath: [CodingKey], willCrashIfJSONEncoder: Bool, topLevelType: EncodedType)
//    
//    /// because the stats Decoder cannot decode from a different encoded value, the values have to be codable to pass through the stats Encoder first
//    public static func allStats<Expected: Codable & Equatable, C: Codable>(for expected: Expected, in codable: C, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> AllStatsResult {
//        
//        let (encodeStats, encoded) = try self._encode(for: expected, in: codable, userInfo: userInfo)
//        
//        do {
//            let result = try VoidDecoder<Expected>(options: (), userInfo: userInfo).start(with: encoded) as C
//            print(result)
//            fatalError("decoder could not find an encoded value for \(Expected.self) in \(type(of: codable))")
//            
//        } catch let error as DecodingError {
//            
//            if error.context.debugDescription == self._decodingTestDebugDescription {
//                
//                return (
//                    encodeStats.encodePath,
//                    error.context.codingPath,
//                    encodeStats.willCrashIfJSONEncoder,
//                    encodeStats.topLevelType
//                )
//            } else {
//                throw error
//            }
//        }
//    }
    
    // MARK: ExpectedPathEncoder
    
    private static var sharedThrowDescription = "Threw error at expected value"
    
    private class VoidEncoder<Expected: Encodable & Equatable>: EncoderBase {
        
        typealias Options = VoidEncoderOptions<Expected>
        
        var codingPath: [CodingKey]
        var options: Options
        var userInfo: [CodingUserInfoKey : Any]
        var reference: EncoderReference?
        
        required init(codingPath: [CodingKey], options: Options, userInfo: [CodingUserInfoKey : Any], reference: EncoderReference?) {
            self.codingPath = codingPath
            self.options = options
            self.userInfo = userInfo
            self.reference = reference
        }
        
        var storage: [Any] = []
        var canEncodeNewValue: Bool = true
        
        static var usesStringValue: Bool {
            return true
        }
        
        func check<T>(_ value: T, at codingPath: [CodingKey]) throws -> Any {
            
            if value as? Expected == self.options.expected {
                
                if self.options.throwAtExpected {
                    throw EncodingError.invalidValue((), EncodingError.Context(codingPath: codingPath, debugDescription: sharedThrowDescription))
                } else {
                    return "encoded"
                }
                
            } else {
                return ()
            }
        }
        
        func boxNil(              at codingPath: [CodingKey]) throws -> Any { return try self.check(NSNull(), at: codingPath) }
        func box(_ value: Bool  , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Int   , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Int8  , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Int16 , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Int32 , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Int64 , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: UInt  , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: UInt8 , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: UInt16, at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: UInt32, at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: UInt64, at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Float , at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: Double, at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box(_ value: String, at codingPath: [CodingKey]) throws -> Any { return try self.check(value, at: codingPath) }
        func box<T>(_ value: T, at codingPath: [CodingKey]) throws -> Any where T : Encodable {
            
            return try self.check(value, at: codingPath) as? String ?? self.box(default: value, at: codingPath)
        }
        
        // need to break the storage count fix to test if JSONEncoder will crash
        public func reencode<T: Encodable>(_ value: T, at codingPath: [CodingKey], closure: (T, Encoder)throws->Void) throws -> Any {
            
            let previousPath = self.codingPath
            self.codingPath = codingPath
            defer { self.codingPath = previousPath }
            
            let depth = self.storage.count
            
            func getEncoded() -> Any? {
                
                switch self.storage.count {
                case depth + 1: return self.storage.removeLast()
                case depth: return nil
                default:
                    if self.storage.count > depth + 1 {
                        fatalError("\(type(of: value)) encoded multiple containers to storage (this is an encoder error; use .canEncodeNewValue and remove storage after throwing). codingPath: \(codingPath)")
                    } else {
                        fatalError("encoder lost values from storage while encoding \(type(of: value)).")
                    }
                }
            }
            
            self.canEncodeNewValue = true
            
            do {
                try closure(value, self)
            } catch {
                // the only change
//                _ = getEncoded()
                throw error
            }
            
            return getEncoded() ?? { ()->Any in fatalError("\(type(of: value)) did not encode a value or container at codingPath: \(codingPath).") }()
        }
        
        deinit {
            if self.storage.count > 1 && self.reference != nil {
                self.options.willCrashIfJSONEncoder = true
                self.storage = []
            }
            self.willDeinit()
        }
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            self.options.checkTopLevel(.keyed)
            return self._container(keyedBy: type)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            self.options.checkTopLevel(.unkeyed)
            return self._unkeyedContainer()
        }
    }
    
    /// a Decoder that throws if Expected.Type is decoded or decodes empty initialized values
    private class VoidDecoder<Expected: Decodable>: DecoderBase {
        
        typealias Options = ()
        
        var codingPath: [CodingKey]
        var options: Options
        var userInfo: [CodingUserInfoKey : Any]
        
        required init(codingPath: [CodingKey], options: Options, userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.options = options
            self.userInfo = userInfo
        }
        
        var storage: [Any] = []
        
        static var usesStringValue: Bool {
            return true
        }
        
        var decodingFromVoid: Bool = false
        
        func start<T>(with value: Any) throws -> T where T : Decodable {
            self.decodingFromVoid = value is Void
            return try self.unbox(value, at: [])
        }
        
        func check<T>(_ value: Any, to: T.Type, at codingPath: [CodingKey]) throws {
            
            if T.self is Expected.Type && (self.decodingFromVoid || value as? String == "encoded") {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: sharedThrowDescription))
            }
        }
        
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Bool   { try self.check(value, to: Bool  .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Int    { try self.check(value, to: Int   .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Int8   { try self.check(value, to: Int8  .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Int16  { try self.check(value, to: Int16 .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Int32  { try self.check(value, to: Int32 .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Int64  { try self.check(value, to: Int64 .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> UInt   { try self.check(value, to: UInt  .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> UInt8  { try self.check(value, to: UInt8 .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> UInt16 { try self.check(value, to: UInt16.self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> UInt32 { try self.check(value, to: UInt32.self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> UInt64 { try self.check(value, to: UInt64.self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Float  { try self.check(value, to: Float .self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Double { try self.check(value, to: Double.self, at: codingPath) ; return .init() }
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> String { try self.check(value, to: String.self, at: codingPath) ; return .init() }
        func unbox<T>(_ value: Any, at codingPath: [CodingKey]) throws -> T where T : Decodable {
            
            try self.check(value, to: T.self, at: codingPath)
            
            return try self.unbox(default: value, at: codingPath)
        }
        
        func keyedContainerContainer(_ value: Any, at codingPath: [CodingKey], _ containerDescription: String) throws -> DecoderKeyedContainerContainer {
            
            if self.decodingFromVoid {
                return LimitedContainer()
            } else if let value = value as? NSDictionary {
                return value
            } else {
                throw self.failedToUnbox(value, to: NSDictionary.self, containerDescription, at: codingPath)
            }
        }
        
        func unkeyedContainerContainer(_ value: Any, at codingPath: [CodingKey], _ containerDescription: String) throws -> DecoderUnkeyedContainerContainer {
            
            if self.decodingFromVoid {
                return LimitedContainer()
            } else if let value = value as? NSArray {
                return value
            } else {
                throw self.failedToUnbox(value, to: NSArray.self, containerDescription, at: codingPath)
            }
        }
    }
    
    /// a container that returns Void with 2 values
    /// returns Void to avoid throwing a value not found unless the value is an array.
    private class LimitedContainer: DecoderKeyedContainerContainer, DecoderUnkeyedContainerContainer {
        var maxCount: Int {
            return 2
        }
        
        func fromStorage(_ index: Int) -> Any { return () }
        var storageCount: Int? { return self.maxCount }
        func isAtEnd(index: Int) -> Bool { return index < self.maxCount }
        
        func value(forStringValue key: String) -> Any? { return () }
        func value(forIntValue key: Int) -> Any? { return () }
        var stringValueKeys: [String] { return [String](repeating: "", count: self.maxCount) }
        var intValueKeys: [Int] { return [Int](repeating: 0, count: self.maxCount) }
    }
    
    
    // MARK: Fails
    
    /// a value for automatic pretty printed test fails
    public struct Fails {
        
        public var test: String
        public var max: UInt32
        
        public init(forTest test: String, max: UInt32) {
            self.test = test
            self.max = max
        }
        
        private var fails: [CustomStringConvertible] = []
        
        var isEmpty: Bool {
            return self.fails.isEmpty
        }
        
        public mutating func add(_ test: CustomStringConvertible?) {
            
            if let fail = test {
                self.fails.append(fail)
            }
        }
        
        public mutating func add(_ fail: CustomStringConvertible) {
            
            self.fails.append(fail)
        }
        
        /// returns the errors, limited by count or nil if empty
        public mutating func result() -> CustomStringConvertible? {
            defer { self.fails.removeAll() }
            return self.current()
        }
        
        public func current() -> CustomStringConvertible? {
            
            let count = UInt32(self.fails.count)
            
            if self.isEmpty {
                return nil
                
            } else if count > self.max {
                
                let fails = self.fails.slice(at: 0, count: Int(self.max))!
                
                return "\n\n\(fails.count) out of \(count) fails for: \(self.test)\n\n" + fails.enumerated().map { "\($0): \($1)" }.joined(separator: "\n\n") + "\n\n"
                
            } else {
                
                return "\n\n\(count) fails for: \(self.test)\n\n" + self.fails.enumerated().map { "\($0): \($1)" }.joined(separator: "\n\n") + "\n\n"
            }
        }
    }
    
    // MARK: Objects
    
    public struct Objects {
        
        public typealias TestObject = CodableTestObject
        public typealias NestableTestObject = CoderNestableTestObject
        
        // MARK: Single
        
        // a codable and equatable optional that is never nil
        public struct NestableOptional<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            public func encode(to encoder: Encoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                try Optional.some(self.value).__encode(to: encoder)
            }
            
            public init(from decoder: Decoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                switch try Optional<T>(__from: decoder) {
                case .some(let value): self.value = value
                case .none:
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Failed to get value from decoded"
                        )
                    )
                }
            }
            
            public static func ==(lhs: NestableOptional, rhs: NestableOptional) -> Bool {
                return lhs.value == rhs.value
            }
        }
        
        // A codable and equatable Optional
        public enum CEOptional<Wrapped: TestObject>: TestObject, ExpressibleByNilLiteral {
            
            case some(Wrapped)
            case none
            
            public init(_ wrapped: Wrapped) {
                self = .some(wrapped)
            }

            public func asOptional() -> Wrapped? {
                switch self {
                case .some(let wrapped): return wrapped
                case .none: return nil
                }
            }
            
            // ExpressibleByNilLiteral
            
            public init(nilLiteral: ()) {
                self = .none
            }
            
            // Codable
            
            public func encode(to encoder: Encoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                try self.asOptional().__encode(to: encoder)
            }
            
            public init(from decoder: Decoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                switch try Optional<Wrapped>(__from: decoder) {
                case .some(let wrapped): self = .some(wrapped)
                case .none: self = .none
                }
            }
            
            // Equatable
            
            public static func ==(lhs: CEOptional, rhs: CEOptional) -> Bool {
                return lhs.asOptional() == rhs.asOptional()
            }
        }
        
        public struct Single<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            // Codable
            
            public func encode(to encoder: Encoder) throws {
                
                var container = encoder.singleValueContainer()

                try container.encode(self.value)
                
                // cannot use value.encode(to:) because encoder needs to encode value, not value's value
//                try self.value.encode(to: encoder)
            }
            
            public init(from decoder: Decoder) throws {
                
                let container = try decoder.singleValueContainer()

                self.value = try container.decode(T.self)
                
                // cannot use T(from:) because decoder needs to decode T, not T's value
//                self.value = try T(from: decoder)
            }
            
            // Equatable
            
            public static func ==(lhs: Single, rhs: Single) -> Bool {
                return lhs.value == rhs.value
            }
        }
        
        // MARK: Keyed
        
        /// a codable and equatable dictionary that can only be created from a single value for path testing
        public struct NestableDictionary<K: Hashable, T: TestObject>: NestableTestObject {
            
            private var key: K
            private var value: T
            
            public init(_ value: T) {
                
                switch K.self {
                case is Int.Type: self.key = 1 as! K
                case is String.Type: self.key = "1" as! K
                default: fatalError("Unable to create default key for \(K.self) in TestDictionary<\(K.self), \(T.self)> use init(key: value:) or init with String or Int as Key type")
                }
                
                self.value = value
            }
            
            public init(key: K, value: T) {
                self.key = key
                self.value = value
            }
            
            // Codable
            
            public func encode(to encoder: Encoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                try [self.key: self.value].__encode(to: encoder)
            }
            
            public init(from decoder: Decoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                let values = try Dictionary<K, T>(__from: decoder)
                guard values.count == 1 else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Failed to get value from decoded"
                        )
                    )
                }
                self.key = values.first!.key
                self.value = values.first!.value
            }
            
            // Equatable
            
            public static func ==(lhs: NestableDictionary, rhs: NestableDictionary) -> Bool {
                return lhs.value == rhs.value && lhs.key == rhs.key
            }
        }
        
        public struct CEDictionary<K: Hashable, V: TestObject>: TestObject, ExpressibleByDictionaryLiteral, Collection {
            
            private var elements: [K:V]
            
            public init() {
                self.elements = [:]
            }
            
            // Collection
            
            public func index(after i: Dictionary<K, V>.Index) -> Dictionary<K, V>.Index {
                return self.elements.index(after: i)
            }
            
            public var startIndex: Dictionary<K, V>.Index {
                return self.elements.startIndex
            }
            
            public var endIndex: Dictionary<K, V>.Index {
                return self.elements.endIndex
            }
            
            public subscript(position: Dictionary<K, V>.Index) -> Dictionary<K, V>.Element {
                return self.elements[position]
            }
            
            public func makeIterator() -> Dictionary<K,V>.Iterator {
                return self.elements.makeIterator()
            }
            
            // literal
            
            public init(dictionaryLiteral elements: (K, V)...) {
                self.elements = Dictionary(elements)
            }
            
            // Codable
            
            public func encode(to encoder: Encoder) throws {
                
                // FIXME: use default when SR-5206 is fixed
                try self.elements.__encode(to: encoder)
            }
            
            public init(from decoder: Decoder) throws {
                // FIXME: use default when SR-5206 is fixed
                self.elements = try Dictionary(__from: decoder)
            }
            
            // Equatable
            
            public static func ==(lhs: CoderTesting.Objects.CEDictionary<K, V>, rhs: CoderTesting.Objects.CEDictionary<K, V>) -> Bool {
                return lhs.elements == rhs.elements
            }
        }
        
        /// calls container(keyedBy:) twice on the same Encoder/Decoder to simulate super encode(to: encoder)/init(from: decoder)
        public struct SubKeyed1<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            private enum CodingKeys: Int, CodingKey {
                case value = 1
            }
            
            public func encode(to encoder: Encoder) throws {
                
                var container1 = encoder.container(keyedBy: CodingKeys.self)
                try container1.encode(self.value, forKey: .value)
                // super.encode(to:)
                var container2 = encoder.container(keyedBy: CodingKeys.self)
                try container2.encode(self.value, forKey: .value)
            }
            
            public init(from decoder: Decoder) throws {
                
                let container1 = try decoder.container(keyedBy: CodingKeys.self)
                self.value = try container1.decode(T.self, forKey: .value)
                // super.init(from:)
                let container2 = try decoder.container(keyedBy: CodingKeys.self)
                _ = try container2.decode(T.self, forKey: .value)
            }
            
            public static func ==(lhs: SubKeyed1, rhs: SubKeyed1) -> Bool {
                
                return lhs.value == rhs.value
            }
        }
        
        /**
         Codes to the encoder/decoder and a superEncoder/superDecoder using the keyed container's superEncoder()/superDecoder()
         to simulate super encode(to: superEncoder)/init(from: superDecoder)
         */
        public struct SubKeyed2<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            private enum CodingKeys: Int, CodingKey {
                case value = 1
            }
            
            public func encode(to encoder: Encoder) throws {
                
                var container1 = encoder.container(keyedBy: CodingKeys.self)
                try container1.encode(self.value, forKey: .value)
                let superEncoder = container1.superEncoder()
                // super.encode(to: superEncoder)
                var container2 = superEncoder.container(keyedBy: CodingKeys.self)
                try container2.encode(self.value, forKey: .value)
            }
            
            public init(from decoder: Decoder) throws {
                
                let container1 = try decoder.container(keyedBy: CodingKeys.self)
                self.value = try container1.decode(T.self, forKey: .value)
                let superDecoder = try container1.superDecoder()
                // super.init(from: superDecoder)
                let container2 = try superDecoder.container(keyedBy: CodingKeys.self)
                let value2 = try container2.decode(T.self, forKey: .value)
                
                guard self.value == value2 else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container2.codingPath, debugDescription: "super \(type(of: self)) decoded a different value \(self.value) != \(value2)"))
                }
            }
            
            public static func ==(lhs: SubKeyed2, rhs: SubKeyed2) -> Bool {
                return lhs.value == rhs.value
            }
        }
        
        // MARK: Unkeyed
        
        // an codable array with only one value at any time
        public struct NestableArray<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            // Codable
            
            public func encode(to encoder: Encoder) throws {
                
                /// FIXME: use the default encode when SR-5206 is fixed
                // self is not an array (encoder does not see an array), but uses the array's .encode(to:)
                try [self.value].__encode(to: encoder)
            }
            
            public init(from decoder: Decoder) throws {
                
                /// FIXME: use the default init when SR-5206 is fixed
                // self is not an array (decoder does not see an array), but uses the array's .init(from:)
                let array = try Array<T>(__from: decoder)
                
                guard array.count == 1 else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Failed to get value from decoded"
                        )
                    )
                }
                
                self.value = array.first!
            }
            
            public static func ==(lhs: NestableArray, rhs: NestableArray) -> Bool {
                return lhs.value == rhs.value
            }
        }
        
        public struct CEArray<E: TestObject>: TestObject, ExpressibleByArrayLiteral, RangeReplaceableCollection {
            
            private var elements: [E]
            
            public init() {
                self.elements = []
            }
            
            // collection
            
            public func index(after i: Array<E>.Index) -> Array<E>.Index {
                return self.elements.index(after: i)
            }
            
            public var startIndex: Array<E>.Index {
                return self.elements.startIndex
            }
            
            public var endIndex: Array<E>.Index {
                return self.elements.endIndex
            }
            
            public subscript(position: Array<E>.Index) -> Array<E>.Element {
                return self.elements[position]
            }
            
            public func makeIterator() -> Array<E>.Iterator {
                return self.elements.makeIterator()
            }
            
            // literal
            
            public init(arrayLiteral elements: E...) {
                self.elements = elements
            }
            
            // Equatable
            
            public static func ==(lhs: CoderTesting.Objects.CEArray<E>, rhs: CoderTesting.Objects.CEArray<E>) -> Bool {
                return lhs.elements == rhs.elements
            }
        }
        
        /// calls unkeyedContainer twice on the same Encoder/Decoder to simulate super encode(to: encoder)/init(from: decoder)
        public struct SubUnkeyed1<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            public func encode(to encoder: Encoder) throws {
                
                var container1 = encoder.unkeyedContainer()
                try container1.encode(self.value)
                // super.encode(to:)
                var container2 = encoder.unkeyedContainer()
                try container2.encode(self.value)
            }
            
            public init(from decoder: Decoder) throws {
                
                var container1 = try decoder.unkeyedContainer()
                self.value = try container1.decode(T.self)
                // super.init(from:)
                var container2 = try decoder.unkeyedContainer()
                _ = try container2.decode(T.self)
            }
            
            public static func ==(lhs: SubUnkeyed1, rhs: SubUnkeyed1) -> Bool {
                
                return lhs.value == rhs.value
            }
        }
        
        /**
         Codes to the encoder/decoder and a superEncoder/superDecoder using the unkeyed container's superEncoder/superDecoder function
         to simulate super encode(to: superEncoder)/init(from: superDecoder)
         */
        public struct SubUnkeyed2<T: TestObject>: NestableTestObject {
            
            public var value: T
            
            public init(_ value: T) {
                self.value = value
            }
            
            public func encode(to encoder: Encoder) throws {
                
                var container1 = encoder.unkeyedContainer()
                try container1.encode(self.value)
                let superEncoder = container1.superEncoder()
                // super.encode(to: superEncoder)
                var container2 = superEncoder.unkeyedContainer()
                try container2.encode(self.value)
            }
            
            public init(from decoder: Decoder) throws {
                
                var container1 = try decoder.unkeyedContainer()
                self.value = try container1.decode(T.self)
                let superDecoder = try container1.superDecoder()
                // super.init(from: superDecoder)
                var container2 = try superDecoder.unkeyedContainer()
                let value2 = try container2.decode(T.self)
                
                guard self.value == value2 else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container2.codingPath, debugDescription: "super \(type(of: self)) decoded a different value \(self.value) != \(value2)"))
                }
            }
            
            public static func ==(lhs: SubUnkeyed2, rhs: SubUnkeyed2) -> Bool {
                
                return lhs.value == rhs.value
            }
        }
        
        /// adds a should be more than one value to a referencing encoder's storage before encoding the value
        public struct MultipleStore<T: TestObject>: NestableTestObject {
            
            public var value: Next
            
            public init(_ value: T) {
                self.value = Next(value)
            }
            
            public func encode(to encoder: Encoder) throws {
                
                var container1 = encoder.unkeyedContainer()
                let superEncoder = container1.superEncoder()
                var container2 = superEncoder.unkeyedContainer()
                try container2.encode(self.value)
            }
            
            public init(from decoder: Decoder) throws {
                
                var container1 = try decoder.unkeyedContainer()
                let superDecoder = try container1.superDecoder()
                var container2 = try superDecoder.unkeyedContainer()
                self.value = try container2.decode(Next.self)
            }
            
            public static func ==(lhs: MultipleStore, rhs: MultipleStore) -> Bool {
                return lhs.value == rhs.value
            }
            
            public struct Next: TestObject {
                
                public var value: T
                
                public init(_ value: T) {
                    self.value = value
                }
                
                public func encode(to encoder: Encoder) throws {
                    
                    var container1 = encoder.unkeyedContainer()
                    try container1.encode(self.value)
                }
                
                public init(from decoder: Decoder) throws {
                    
                    var container1 = try decoder.unkeyedContainer()
                    self.value = try container1.decode(T.self)
                }
                
                public static func ==(lhs: Next, rhs: Next) -> Bool {
                    return lhs.value == rhs.value
                }
            }
        }
    }
}

public typealias CodableTestObject = Codable & Equatable

// a codable and equatable
public protocol CoderNestableTestObject: CodableTestObject {
    
    associatedtype Value: CodableTestObject
    
    init(_ value: Value)
}

//public protocol EmptyInitialable {
//    init()
//}
//
//extension String: EmptyInitialable {}
//extension Int: EmptyInitialable {}
//
///// represents a coder function call to enable tests to create or use a CodingKey
//public enum CoderCodingPathCall {
//
//    case container(keyedBy: CodingKey)
//    case unkeyedContainer(index: Int)
//    case unkeyedContainerUnknownIndex
//    case superCoder
//}
//
//public protocol EncodableTestObject: Encodable, Equatable {
//
//    static var encodePathCalls: [CoderCodingPathCall] {get}
//}
//
//public protocol DecodableTestObject: Decodable, Equatable {
//
//    static var decodePathCalls: [CoderCodingPathCall] {get}
//}
//
//public protocol CodableTestObject: EncodableTestObject, DecodableTestObject {
//
//    static var codingPathCalls: [CoderCodingPathCall] {get}
//}
//
//extension CodableTestObject {
//
//    public static var encodePathCalls: [CoderCodingPathCall] {return self.codingPathCalls}
//    public static var decodePathCalls: [CoderCodingPathCall] {return self.codingPathCalls}
//}

// MARK: CharacterSet

fileprivate extension CharacterSet {

    func allCharacters() -> [Character] {
        var result: [Character] = []
        for plane: UInt8 in 0...16 where self.hasMember(inPlane: plane) {
            for unicode in UInt32(plane) << 16 ..< UInt32(plane + 1) << 16 {
                if let uniChar = UnicodeScalar(unicode), self.contains(uniChar) {
                    result.append(Character(uniChar))
                }
            }
        }
        return result
    }
}

