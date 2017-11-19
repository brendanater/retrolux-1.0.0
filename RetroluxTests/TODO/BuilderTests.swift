//
//  BuilderTests.swift
//  RetroluxTests
//
//  Created by Brendan Henderson on 9/14/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation
import XCTest
import Retrolux

class BuilderTests: XCTestCase {
    
    func testMethods() {
        let builder = makeTestBuilder()
        
        func test(_ method: URLRequest.HTTPMethod) {
            
            let request = builder.makeRequest(method, "whatever/whatevs")
            
            switch method {
            case .get       : XCTAssert(request.httpMethod == "GET"     )
            case .post      : XCTAssert(request.httpMethod == "POST"    )
            case .connect   : XCTAssert(request.httpMethod == "CONNECT" )
            case .delete    : XCTAssert(request.httpMethod == "DELETE"  )
            case .head      : XCTAssert(request.httpMethod == "HEAD"    )
            case .options   : XCTAssert(request.httpMethod == "OPTIONS" )
            case .patch     : XCTAssert(request.httpMethod == "PATCH"   )
            case .put       : XCTAssert(request.httpMethod == "PUT"     )
            case .trace     : XCTAssert(request.httpMethod == "TRACE"   )
            }
            
            XCTAssert(request.url == URL(string: builder.base.absoluteString + "whatever/whatevs")!)
        }
        
        test(.get)
        test(.post)
        test(.connect)
        test(.delete)
        test(.head)
        test(.options)
        test(.patch)
        test(.put)
        test(.trace)
    }
    
    func testPathEscaping() {
//        let builder = self.makeBuilder()
//        let endpoint = "some_endpoint/?query=value a"
//        let expected = endpoint.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
//        let request = builder.makeRequest(.get, endpoint)
//
//        let response = ClientResponse(request as URLRequest, nil as Data?, nil, nil)
//        XCTAssert(
//            response.originalRequest.url?.absoluteString == builder.base.absoluteString + expected,
//            "response URL incorrect: \(response.originalRequest.url?.absoluteString ?? "nil") vs \(builder.base.absoluteString + expected)"
//        )
        XCTFail()
    }
    
    func testInterception() {
        XCTFail()
    }
    
    func testEncodeWithEncoders() {
        XCTFail()
    }
    
    func testDecodeWithDecoders() {
        XCTFail()
    }
    
    func testMakeCall() {
        XCTFail()
    }
    
    func testMakeCallWithOtherArgs() {
        XCTFail()
    }
    
    
    
    
    
}

