//
//  Body.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/13/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol RequestBody: RequestArg {
    func requestBody() throws -> Body
}

extension RequestBody {
    public func apply(to request: inout URLRequest) throws {
        
        let body = try self.requestBody()
        
        guard case let .data(data) = body.data else {
            // cannot use request.httpBodyStream, because there are no callbacks in URLSession and there would be confusion when overriding httpBody.
            throw Body.BodyError.cannotSetBodyDataAtURLToURLRequestUseUploadTaskType
        }
        
        request.httpBody = data
        request.httpHeaders = body.httpHeaders
    }
}

public struct Body: RequestArg, RequestBody {
    
    public var data: AnyData
    public var httpHeaders: HTTPHeaders
    
    public init(_ data: AnyData, _ httpHeaders: HTTPHeaders) {
        
        self.data = data
        self.httpHeaders = httpHeaders
    }
    
    /// returns self to conform to RequestBody
    public func requestBody() throws -> Body {
        return self
    }
    
    public enum BodyError: Error {
        case cannotSetBodyDataAtURLToURLRequestUseUploadTaskType
    }
}
