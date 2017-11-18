//
//  Query.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/10/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

extension URLQueryItem: RequestArg {
    
    public init(_ name: String, _ value: String?) {
        self.init(name: name, value: value)
    }
    
    /// adds self to the request.url's query, if it has a query.
    public func apply(to request: inout URLRequest) throws {
        
        request.urlComponents?.queryItems?.append(self)
    }
}

/// Field is a typealias to Query, so you'll need to set the stategy to set to body
public typealias Field = Query

/// always replaces all query items
public struct Query: RequestArg, RequestBody {
    
    public var items: [URLQueryItem]
    
    public var strategy: ApplicationStrategy = .methodDependent(.utf8)
    
    public var query: String {
        get {
            return items.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        }
        set {
            self.items = URL(string: "?" + newValue)?.queryItems ?? []
        }
    }
    
    // init
    
    public init(_ items: (name: String, value: String?)...) {
        self.init(items)
    }
    
    public init(_ items: [(name: String, value: String?)]) {
        self.items = items.map { URLQueryItem(name: $0.name, value: $0.value) }
    }
    
    public init(_ name: String, _ value: String?) {
        self.items = [URLQueryItem(name, value)]
    }
    
    public init(_ items: [URLQueryItem]) {
        self.items = items
    }
    
    public init<T: Encodable>(_ value: T, with encoder: URLEncoder = URLEncoder()) throws {
        self.items = try encoder.encode(asQueryItems: value)
    }
    
    // apply
    
    public func apply(to request: inout URLRequest) throws {
        
        try self.strategy.apply(self.items, to: &request)
    }
    
    public func requestBody() throws -> Body {
        
        return try Query.body(for: self.items)
    }
    
    public static func body(for queryItems: [URLQueryItem], encoding: String.Encoding = .utf8) throws -> Body {
        
        var components = URL(string: "?")!.components!
        
        components.queryItems = queryItems
        
        guard let httpBody = components.query?.data(using: encoding) else {
            throw QueryApplyError.failedToGetHTTPBody(withItems: queryItems)
        }
        
        var httpHeaders = HTTPHeaders()
        
        httpHeaders[.contentLength] = httpBody.count.description
        httpHeaders[.contentType] = "application/x-www-form-urlencoded" + (encoding.charset.map { "; charset=\($0)" } ?? "")
        
        return Body(.data(httpBody), httpHeaders)
    }
    
    // strategy
    
    public enum QueryApplyError: Error {
        
        case failedToGetHTTPBody(withItems: [URLQueryItem])
    }
    
    public enum ApplicationStrategy {
        
        /// set queryItems to URL
        case url
        case httpBody(String.Encoding)
        /// request's httpMethod defines whether to apply to url or httpBody
        case methodDependent(String.Encoding)
        
        public static var httpBodyUTF8: ApplicationStrategy {
            return .httpBody(.utf8)
        }
        public static var methodDependentUTF8: ApplicationStrategy {
            return .methodDependent(.utf8)
        }
        
        /// applies URL to
        public func apply(_ queryItems: [URLQueryItem], to request: inout URLRequest) throws {
            
            func setToURL() {
                
                request.urlComponents?.queryItems = queryItems
            }
            
            func setToBody(_ encoding: String.Encoding) throws {
                
                request.query = nil
                
                try Query.body(for: queryItems, encoding: encoding).apply(to: &request)
            }
            
            switch self {
            case .methodDependent(let encoding):
                
                switch request.httpMethod_enum ?? .get {
                case .get, .head, .delete: setToURL()
                default: try setToBody(encoding)
                }
                
            case .url:
                setToURL()
                
            case .httpBody(let encoding):
                try setToBody(encoding)
            }
        }
    }
}
