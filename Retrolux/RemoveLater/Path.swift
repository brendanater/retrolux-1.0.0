//
//  Path.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/13/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation



//public struct Path: RequestArg {
//    
//    /// the identifier of where in the path to replace.  example: "id" in "users/{id}/"
//    public let identifier: String
//    public let value: String
//    
//    public init(_ identifier: String, _ value: String) {
//        self.identifier = identifier
//        self.value = value
//    }
//    
//    public init(_ identifier: String, _ value: Int) {
//        self.identifier = identifier
//        self.value = value.description
//    }
//    
//    /// replaces occurrances of "{\(self.identifier)}" in the request.url?.path with self.value
//    public func apply(to request: inout URLRequest) throws {
//        
//        let path = request.url?.path.replacingOccurrences(of: "%7B\(self.identifier)%7D", with: self.value) ?? ""
//        request.urlComponents?.path = path
//    }
//}

