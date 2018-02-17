//
//  Body.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


public struct Body: RequestBody {
    
    public var data: DataBody
    public var httpHeaders: HTTPHeaders
    
    public init(_ data: DataBody, _ httpHeaders: HTTPHeaders) {
        
        self.data = data
        self.httpHeaders = httpHeaders
    }
    
    public init(_ data: Data, _ httpHeaders: HTTPHeaders) {
        self.init(.data(data), httpHeaders)
    }
    
    /// returns self to conform to RequestBody
    public func requestBody() throws -> Body {
        return self
    }
}
