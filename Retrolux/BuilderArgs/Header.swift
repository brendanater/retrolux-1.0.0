//
//  HTTPHeaders.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/2/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public typealias Headers = HTTPHeaders

public struct Header: RequestArg {
    
    public typealias Field = HTTPHeaders.Field
    
    public var field: Field
    public var value: String
    
    public init(_ field: Field, _ value: String) {
        self.field = field
        self.value = value
    }
    
    public func apply(to request: inout URLRequest) throws {
        request.httpHeaders[self.field] = value
    }
}

extension URLRequest {
    
    public var httpHeaders: HTTPHeaders {
        get {
            return HTTPHeaders(self.allHTTPHeaderFields)
        }
        set {
            if newValue.isEmpty {
                
                self.allHTTPHeaderFields = nil
                
            } else if newValue.replacesAllFields {
                    
                self.allHTTPHeaderFields = newValue.allFields
                
            } else {
                
                var headers = self.allHTTPHeaderFields ?? [:]
                
                for (key, value) in newValue.allFields {
                    headers[key] = value
                }
                
                self.allHTTPHeaderFields = headers
            }
        }
    }
}

extension HTTPURLResponse {
    
    public var httpHeaders: HTTPHeaders {
        return HTTPHeaders(self.allHeaderFields as? [String: String])
    }
}

public struct HTTPHeaders: Sequence, ExpressibleByDictionaryLiteral, RequestArg {
    
    public var fields: [Field: String]
    
    /// headers reduced to/from self.fields
    public var allFields: [String: String] {
        get {
            return self.fields.reduce(into: [:], { $0[$1.key.name] = $1.value })
        }
        set {
            self.fields = newValue.reduce(into: [:], { $0[Field($1.key)] = $1.value })
        }
    }
    
    /// whether to replace or add fields to a URLRequest
    public var replacesAllFields: Bool = true
    
    public init() {
        self.fields = [:]
    }
    
    public init(_ allHTTPHeaderFields: [String: String]?) {
        
        self.init()
        self.allFields = allHTTPHeaderFields ?? [:]
    }
    
    public init(dictionaryLiteral elements: (Field, String)...) {
        self.init(elements)
    }
    
    public init(_ fields: (name: Field, value: String)...) {
        self.init(fields)
    }
    
    public init(_ fields: [(name: Field, value: String)]) {
        self.fields = fields.reduce(into: [:], { $0[$1.0] = $1.1 })
    }
    
    public init(_ field: Field, _ value: String) {
        self.fields = [field: value]
    }
    
    public struct Field: ExpressibleByStringLiteral, Hashable {
        
        public var name: String
        
        public init(_ name: String) {
            self.name = name
        }
        
        public init(stringLiteral value: String) {
            self.name = value
        }
        
        public var hashValue: Int {
            return self.name.hashValue
        }
        
        public static func ==(lhs: HTTPHeaders.Field, rhs: HTTPHeaders.Field) -> Bool {
            return lhs.name == rhs.name
        }
        
        /// "Content-Disposition" rfc: https://tools.ietf.org/html/rfc6266#section-4.1
        public static let contentDisposition: Field = "Content-Disposition"
        /// "Content-Type" rfc: https://www.ietf.org/rfc/rfc2045.txt#section-5.1
        public static let contentType       : Field = "Content-Type"
        /// "Content-Length" The length in decimal number of octets
        public static let contentLength     : Field = "Content-Length"
    }
    
    public subscript(field: Field) -> String? {
        get {
            return self.fields[field]
        }
        set {
            self.fields[field] = newValue
        }
    }
    
    public var isEmpty: Bool {
        return self.fields.isEmpty
    }
    
    public func apply(to request: inout URLRequest) throws {
        request.httpHeaders = self
    }
    
    public func makeIterator() -> Dictionary<Field, String>.Iterator {
        return self.fields.makeIterator()
    }
}

public protocol HTTPHeaderProtocol: CustomStringConvertible {
    
    static var field: HTTPHeaders.Field {get}
}

