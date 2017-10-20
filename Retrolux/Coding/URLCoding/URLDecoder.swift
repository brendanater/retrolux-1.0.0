//
//  URLDecoder.swift
//  URLEncoder
//
//  Created by Brendan Henderson on 8/31/17.
//  Copyright © 2017 OKAY. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation



public struct URLDecoder: TopLevelDecoder {
    
    // options
    
    public var serializer = URLQuerySerializer()
    
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    public var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData
    public var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw
    
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    public init() {}
    
    //
    
    private var options: Base.Options {
        return ((
            self.dateDecodingStrategy,
            self.dataDecodingStrategy,
            self.nonConformingFloatDecodingStrategy
        ), (
            self.serializer.boolRepresentation,
            ()
        ))
    }
    
    // decoding
    
    public func decode<T>(_: T.Type, from value: Data) throws -> T where T : Decodable {
        
        let _value: Any
        
        do {
            
            _value = try self.serializer.object(from: value)
            
        } catch {
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Failed to deserialize data",
                    underlyingError: error
                )
            )
        }
        
        return try self.decode(T.self, fromValue: _value)
    }
    
    public func decode<T>(_: T.Type, fromValue value: Any) throws -> T where T : Decodable {
        
        return try Base(options: self.options, userInfo: self.userInfo).start(with: value)
    }
    
    // extra decode methods
    
    /// decode from query string
    public func decode<T>(_: T.Type, from value: String) throws -> T where T : Decodable {
        
        let _value: Any
        
        do {
            
            _value = try self.serializer.object(from: value)
            
        } catch {
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Failed to deserialize query",
                    underlyingError: error
                )
            )
        }
        
        return try self.decode(T.self, fromValue: _value)
    }
    
    /// decode from queryItems
    public func decode<T>(_: T.Type, from value: [URLQueryItem]) throws -> T where T : Decodable {
        
        let _value: Any
        
        do {
            
            _value = try self.serializer.object(from: value)
            
        } catch {
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Failed to deserialize query items",
                    underlyingError: error
                )
            )
        }
        
        return try self.decode(T.self, fromValue: _value)
    }
    
    // Base
    
    fileprivate class Base: DecoderJSONBase {
        
        static var usesStringValue: Bool = true
        
        typealias ExtraOptions = (boolRepresentation: (true: String, false: String), ())
        typealias Options = JSONOptions
        
        var codingPath: [CodingKey]
        var options: Options
        var userInfo: [CodingUserInfoKey : Any]
        
        required init(codingPath: [CodingKey], options: Options, userInfo: [CodingUserInfoKey : Any]) {
            self.options = options
            self.userInfo = userInfo
            self.codingPath = codingPath
        }
        
        var storage: [Any] = []
        
        // URLDecoder methods
        
        /// get a container from a tuple array or a dictionary
        func keyedContainerContainer(_ value: Any, at codingPath: [CodingKey], nested: Bool) throws -> DecoderKeyedContainerContainer {
            
            if let value = value as? [(String, Any)] {
                
                let result: NSMutableDictionary = [:]
                
                for (key, value) in value {
                    result[key] = value
                }
                
                return result as NSDictionary
                
            } else if let value = value as? NSDictionary {
                
                return value
                
            } else if let value = value as? [Any], value.isEmpty {
                
                return NSDictionary()
                
            } else {
                
                throw self.failedToUnbox(value, to: NSDictionary.self, (nested ? "nested " : "") + "keyed container", at: codingPath)
            }
        }
        
        func unboxNil(_ value: Any) -> Bool {
            return (value as? String)?.isEmpty ?? isNil(value)
        }
        
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> String {
            
            if let value = value as? String, !value.isEmpty {
                return value
            }
            
            throw self.failedToUnbox(value, to: String.self, at: codingPath)
        }
        
        func unbox(_ value: Any, at codingPath: [CodingKey]) throws -> Bool {
            
            if (value as? NSNumber)?.isBoolean ?? false, let value = value as? Bool {
                
                return value
                
            } else if let value = value as? String {
                
                switch value {
                case self.options.extra.boolRepresentation.true: return true
                case self.options.extra.boolRepresentation.false: return false
                default:
                    if let value = Bool(value) {
                        return value
                    }
                }
            }
            
            throw self.failedToUnbox(value, to: Bool.self, at: codingPath)
        }
    }
}














