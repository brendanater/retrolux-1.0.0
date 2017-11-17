//
//  Body.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/13/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol RequestBody {
    func requestBody() throws -> Body
}

public struct Body: RequestBody {
    
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
}
