//
//  HTTPMethod.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case head    = "HEAD"
    case options = "OPTIONS"
    case trace   = "TRACE"
    case connect = "CONNECT"
    
    public init?(_ httpMethod: String?) {
        if let httpMethod = httpMethod {
            self.init(rawValue: httpMethod)
        } else {
            return nil
        }
    }
}

public enum RestHTTPMethod {
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
    
    public var successfulStatusCode: Int {
        switch self {
        case .list, .retrieve, .update, .partialUpdate: return 200
        case .create: return 201
        case .destroy: return 204
        }
    }
    
    public var statusConfirmation: (Int) -> Bool {
        return { [code = self.successfulStatusCode] in $0 == code }
    }
}
