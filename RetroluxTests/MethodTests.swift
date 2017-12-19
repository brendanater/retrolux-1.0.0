//
//  MethodTests.swift
//  RetroluxTests
//
//  Created by Christopher Bryan Henderson on 8/28/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation
import XCTest

@testable import Retrolux

class MethodTests: XCTestCase {
    
    func test() {
        
        let expect = expectation(description: "rr")
        
        google.getUsers([1], callback: { print($0, "finished", try! String.init(data: $0.interpret().asData(), encoding: .utf8)!); expect.fulfill() })
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
