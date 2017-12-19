//
//  HTTPMethod.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
    
    public init?(_ httpMethod: String?) {
        self.init(rawValue: httpMethod?.uppercased() ?? "%%$#")
    }
}

extension NSURLRequest {
    
    open var httpMethod_enum: HTTPMethod? {
        return HTTPMethod(self.httpMethod)
    }
}

extension NSMutableURLRequest {
    
    open func set(httpMethod: HTTPMethod) {
        self.httpMethod = httpMethod.rawValue
    }
}

extension URLRequest {
    
    public var httpMethod_enum: HTTPMethod? {
        get {
            return HTTPMethod(self.httpMethod)
        }
        set {
            self.httpMethod = newValue?.rawValue
        }
    }
    
    public mutating func set(httpMethod: HTTPMethod) {
        self.httpMethod_enum = httpMethod
    }
}
