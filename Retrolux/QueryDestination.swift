//
//  QueryDestination.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/23/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public enum QueryDestination {
    
    case queryString
    case httpBody(String.Encoding)
    /// set to queryString if method == .get, .head, or .delete, else set to httpBody
    case methodDependent(String.Encoding)
    
    public static var httpBodyUTF8: QueryDestination {
        return .httpBody(.utf8)
    }
    
    public static var methodDependentUTF8: QueryDestination {
        return .methodDependent(.utf8)
    }
}

extension QueryDestination {
    
    public var encoding: String.Encoding? {
        switch self {
        case .httpBody(let encoding), .methodDependent(let encoding): return encoding
        default: return nil
        }
    }
    
    public func shouldSetToQuery(withMethod method: HTTPMethod) -> Bool {
        switch self {
        case .queryString: return true
        case .httpBody(_): return false
        case .methodDependent(_):
            switch method {
            case .get, .head, .delete: return true
            default: return false
            }
        }
    }
    
    public func shouldSetToBody(withMethod method: HTTPMethod) -> Bool {
        return !self.shouldSetToQuery(withMethod: method)
    }
}
