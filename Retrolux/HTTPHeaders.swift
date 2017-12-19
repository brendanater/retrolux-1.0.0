//
//  HTTPHeaders.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/2/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

extension URLRequest {
    
    public var httpHeaders: HTTPHeaders {
        get {
            return HTTPHeaders(self.allHTTPHeaderFields)
        }
        set {
            if newValue.isEmpty {
                self.allHTTPHeaderFields = nil
            } else {
                self.allHTTPHeaderFields = newValue.allFields
            }
        }
    }
    
    public mutating func add(httpHeaders: HTTPHeaders) {
            
        var headers = self.allHTTPHeaderFields ?? [:]
        
        for (key, value) in httpHeaders.allFields {
            headers[key] = value
        }
        
        self.allHTTPHeaderFields = headers
    }
}

extension HTTPURLResponse {
    
    public var httpHeaders: HTTPHeaders {
        return HTTPHeaders(self.allHeaderFields as? [String: String])
    }
}

public struct HTTPHeaders: Sequence, ExpressibleByDictionaryLiteral {
    
    public var allFields: [String: String]
    
    /// headers reduced to/from self.allFields
    public var fields: [Field: String] {
        get {
            return self.allFields.reduce(into: [:], { $0[Field($1.key)] = $1.value })
        }
        set {
            self.allFields = newValue.reduce(into: [:], { $0[$1.key.name] = $1.value })
        }
    }
    
    public init() {
        self.allFields = [:]
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
        self.allFields = fields.reduce(into: [:], { $0[$1.0.name] = $1.1 })
    }
    
    public struct Field: ExpressibleByStringLiteral, Hashable {
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
        
        public var name: String
        
        /// "Content-Disposition" rfc: https://tools.ietf.org/html/rfc6266#section-4.1
        public static let contentDisposition: Field = "Content-Disposition"
        /// "Content-Type" rfc: https://www.ietf.org/rfc/rfc2045.txt#section-5.1
        public static let contentType       : Field = "Content-Type"
        /// "Content-Length" The length in decimal number of octets
        public static let contentLength     : Field = "Content-Length"
    }
    
    public subscript(field: Field) -> String? {
        get {
            return self.allFields[field.name]
        }
        set {
            self.allFields[field.name] = newValue
        }
    }
    
    public var isEmpty: Bool {
        return self.allFields.isEmpty
    }
    
    public func makeIterator() -> Dictionary<Field, String>.Iterator {
        return self.fields.makeIterator()
    }
}

