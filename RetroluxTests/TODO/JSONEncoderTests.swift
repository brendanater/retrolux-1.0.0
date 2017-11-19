//
//  JSONEncoderTests.swift
//  RetroluxTests
//
//  Created by Christopher Bryan Henderson on 8/28/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import XCTest
import Retrolux

class JSONEncoderTests: XCTestCase {
//    func testBasicBody() {
//        struct Person: Encodable {
//            let name: String
//        }
//
//        let builder = makeTestBuilder()
//        let request = builder.make(.post, ("users/"), body: JSONEncoder(), response: Void.self)
//        let response = request.test(Person(name: "Bob"), simulated: .empty)
//        XCTAssert(response.request.httpBody == "{\"name\":\"Bob\"}".utf8)
//        XCTAssert(response.request.value(forHTTPHeaderField: "Content-Type") == "application/json")
//    }
    
    // I.e., builder.make(..., body: (Person, Person).self, ...).
    // Whether or not multiple bodies are supported is up to the encoder.
    func testMultipleBodies() {
        XCTFail()
    }
    
    // Decodable but not encodable objects should raise an error that there are no supported encodables.
    func testDecodableButNotEncodable() {
        XCTFail()
    }
    
    func testThrowExceptionDuringEncoding() {
        XCTFail()
    }
    
    // I.e., sending "3" as the body (String is Encodable) instead of an object.
    func testInvalidRootType() {
        XCTFail()
    }
}
