//
//  RequestArg.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/1/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol RequestArg {
    func apply(to request: inout URLRequest) throws
}

public func apply(to request: inout URLRequest, _ args: RequestArg...) throws {
    for arg in args {
        try arg.apply(to: &request)
    }
}

public func apply(to request: inout URLRequest, _ args: [RequestArg]) throws {
    for arg in args {
        try arg.apply(to: &request)
    }
}

