//
//  CallTests.swift
//  RetroluxTests
//
//  Created by Brendan Henderson on 11/16/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation
import XCTest
import Retrolux


class CallTests: XCTestCase {
    
    func testResponseValidators() {
        XCTFail()
    }
    
    func testStatusValidation() {
        XCTFail()
    }
    
    func testTestResponse() {
        
        let _expectation1 = expectation(description: "waiting for response1")
        let _expectation2 = expectation(description: "waiting for response2")
        
        let builder = makeTestBuilder()
        
        let request = builder.makeRequest(.get, "something")
        
        let testResponse = ClientResponse(request as URLRequest, "unique".data(using: .utf8), nil, nil)
        
        request.testResponse = testResponse
        
        do {
            try request.createTask(.dataTask, completionHandler: {
                
                XCTAssert($0 == testResponse)
                
                _expectation1.fulfill()
                
            }).resume()
            
            try request.createTask(.uploadTask(AnyData(Data())), completionHandler: {
                
                XCTAssert($0 == testResponse)
                
                _expectation2.fulfill()
                
            }).resume()
            
            XCTAssert(try request.execute(.dataTask) == testResponse)
            XCTAssert(try request.execute(.downloadTask) == testResponse)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testMethodSetting() {
        XCTFail()
    }
    
    func testExecute() {
        XCTFail()
    }
    
    func testValidationIsCaptured() {
        XCTFail()
    }
}
