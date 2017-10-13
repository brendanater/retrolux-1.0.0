//
//  URLEncoderTests.swift
//  SimplifiedCoderTests
//
//  Created by Brendan Henderson on 9/13/17.
//  Copyright © 2017 OKAY. All rights reserved.
//

import Foundation
import XCTest
@testable
import Retrolux

let r = XCTestSuite.init(name: "TestURLEncoder")

class TestURLEncoder: XCTestCase {
    
    var encoder = URLEncoder()
    
    func encode<T: Encodable>(_ value: T) throws -> Data {
        return try self.encoder.encode(value)
    }

    func testArray() {

        let value = ["key": [1]]
        
        let expectedResult = "key[]=1"

        do {

            let string = try String(data: self.encoder.encode(value), encoding: .utf8)
            
            XCTAssert(string != nil)
            
            XCTAssert(string ?? "" == expectedResult, "Incorrect string: \(string ?? "")")

        } catch {
            XCTFail("\(type(of: error)).\(error)")
        }
    }

    func testNestedArray() {

        let value = [[[[1]]]]

        do {

            _ = try self.encode(value)

            XCTFail()

        } catch EncodingError.invalidValue(let value, let context) {
            
            XCTAssert(value is NSArray)
            
            XCTAssert(context.codingPath.count == 0, context.debugDescription + ". CodingPath: \(context.codingPath)")
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDictionary() {

        let value = ["key": ["key2":1]]
        
        let expectedResult = "key[key2]=1"
        
        do {
            
            let string = try String(data: self.encode(value), encoding: .utf8)
            
            XCTAssert(string != nil)
            
            XCTAssert(string! == expectedResult, "Incorrect result: \(string!)")
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testNestedDictionary() {

        let value = ["key": ["key1":["key2": ["key3": 3], "key4": ["key5": 4]]]]
        
        let expectedResult = "key[key1][key2][key3]=3&key[key1][key4][key5]=4"
        
        do {
            
            let string = try String(data: self.encode(value), encoding: .utf8)
            
            XCTAssert(string != nil)
            
            XCTAssert(string! == expectedResult, "Incorrect result: \(string!)")
            
        } catch {
            XCTFail("Error was thrown: \(error)")
        }
    }

    func testMixedDictionaryAndArray() {

        let value = ["key1":["key2": ["key3": [["key4": ["key5": [[[["key6": [1]]]]]]]]]]]

        do {

            let value2 = try String(data: self.encode(value), encoding: .utf8)

            XCTFail("encoder did not throw: \(value2 ?? "<void>__")")

        } catch EncodingError.invalidValue(let value, let context) {
            
            XCTAssert(value is NSDictionary)
            
            XCTAssert(context.underlyingError is URLQuerySerializer.ToQueryError?)
            
            XCTAssert(context.codingPath.count == 0)
            
            if let error = context.underlyingError {
                do {
                    throw error
                } catch URLQuerySerializer.ToQueryError.nestedContainerInArray {
                    
                } catch {
                    XCTFail("\(error)")
                }
            }
            
        } catch {
            XCTFail("Worng error: \(error)")
        }
    }

    class Object1: Codable {
        var value = 1
        var array = [1]
        var dictionary = ["key": 2]
        var nestedDictionary = ["key": [1]]
    }

    class WithNestedClass: Codable {
        class Nested: Codable {
            class NestedNested: Codable {
                var value = 1
            }
            
            var value = 1
            var nested = NestedNested()
        }

        var value = 1
        var value2 = "test"
        var nested = Nested()
    }

    func testObject() {

        let value = Object1()
        
        let expectedResult = "value=1&array[]=1&dictionary[key]=2&nestedDictionary[key][]=1"
        
        do {
            
            let string = try String(data: self.encode(value), encoding: .utf8)
            
            XCTAssert(string == expectedResult, "Incorrect result: \(string!)")
            
        } catch {
            XCTFail("Error was thrown: \(error)")
        }
    }

    func testNestedObject() {

        let value = WithNestedClass()
        
        let expectedResult = "value=1&value2=test&nested[value]=1&nested[nested][value]=1"
        
        do {
            
            let string = try String(data: self.encode(value), encoding: .utf8)
            
            XCTAssert(string != nil)
            
            XCTAssert(string! == expectedResult, "Incorrect result: \(string!)")
            
        } catch {
            XCTFail("Error was thrown: \(error)")
        }
    }
    
    // skip path tests because URLEncoder does not add any special functions to path handling
}















