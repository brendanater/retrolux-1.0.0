//
//  HTTPMethod.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public enum RestfulHTTPMethod {
    case list, create, retrieve, update, partialUpdate, destroy
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .list, .retrieve: return .get
        case .create: return .post
        case .update: return .put
        case .partialUpdate: return .patch
        case .destroy: return .delete
        }
    }
    
    public var statusConfirmation: (Int) -> Bool {
        switch self {
        case .list, .retrieve, .update, .partialUpdate: return { $0 == 200 }
        case .create: return { $0 == 201 }
        case .destroy: return { $0 == 204 }
        }
    }
}

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
    
    open var httpMethodEnum: HTTPMethod? {
        return HTTPMethod(self.httpMethod)
    }
}

extension NSMutableURLRequest {
    
    open func set(httpMethod: HTTPMethod) {
        self.httpMethod = httpMethod.rawValue
    }
}

extension URLRequest {
    
    public var httpMethodEnum: HTTPMethod? {
        get {
            return HTTPMethod(self.httpMethod)
        }
        set {
            self.httpMethod = newValue?.rawValue
        }
    }
    
    public mutating func set(httpMethod: HTTPMethod) {
        self.httpMethodEnum = httpMethod
    }
}
