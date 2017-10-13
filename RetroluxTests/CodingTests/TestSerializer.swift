//
//  TestSerializer.swift
//  RetroluxTests
//
//  Created by Brendan Henderson on 9/27/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

import Retrolux

// MARK: TestSerializer

struct TestSerializer {
    
    enum NotValid: Error {
        case notValid(Any)
    }
    
    static func serialize(_ value: Any) throws -> Data {
        try self.assertValidObject(value)
        return try JSONSerialization.data(withJSONObject: value)
    }
    
    static func deserialize(_ data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data)
    }
    
    static func assertValidObject(_ value: Any) throws {
        
        switch value {
            
        case is NSDictionary:
            
            for (_, value) in value as! NSDictionary {
                try assertValidObject(value)
            }
            
            
        case is NSArray:
            
            for value in value as! NSArray {
                try assertValidObject(value)
            }
            
        case is Bool  : return
        case is Int   : return
        case is Int8  : return
        case is Int16 : return
        case is Int32 : return
        case is Int64 : return
        case is UInt  : return
        case is UInt8 : return
        case is UInt16: return
        case is UInt32: return
        case is UInt64: return
        case is Float : return
        case is Double: return
        case is String: return
            
        default:
            if isNil(value) {
                return
                
            } else {
                
                throw NotValid.notValid(value)
            }
        }
    }
}
