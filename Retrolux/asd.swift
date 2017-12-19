//
//  asd.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


public protocol Copyable {
    init(copy: Self)
}

extension Copyable {
    public func copy() -> Self {
        return Self(copy: self)
    }
}

public enum QueryDestination {
    
    case queryString
    case httpBody(String.Encoding)
    /// queryString if method == .get, .head, or .delete, else httpBody
    case methodDependent(String.Encoding)
    
    public static var httpBodyUTF8: QueryDestination {
        return .httpBody(.utf8)
    }
    
    public static var methodDependentUTF8: QueryDestination {
        return .methodDependent(.utf8)
    }
}

public enum RestfulHTTPMethod {
    case list, create, retrieve, update, partialUpdate, destroy
    
    public var httpMethod: String {
        switch self {
        case .list, .retrieve: return "GET"
        case .create: return "POST"
        case .update: return "PUT"
        case .partialUpdate: return "PATCH"
        case .destroy: return "DELETE"
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
