//
//  Response.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol HasURLResponse {
    var urlResponse: URLResponse? {get}
}

extension HasURLResponse {
    
    // convenience URLResponse methods
    
    public var httpURLResponse: HTTPURLResponse? {
        return self.urlResponse as? HTTPURLResponse
    }
    
    public var statusCode: Int? {
        return self.httpURLResponse?.statusCode
    }
    
    public var mimeType: String? {
        return self.urlResponse?.mimeType
    }
    
    public var allHeaderFields: [String: String]? {
        return self.httpURLResponse?.allHeaderFields as? [String: String]
    }
    
    public var httpHeaders: HTTPHeaders {
        return HTTPHeaders(self.allHeaderFields)
    }
}

public struct Response<T>: HasURLResponse {
    
    public enum Result {
        case success(T)
        case failure(Error)
    }
    
    public var result: Result
    public let urlResponse: URLResponse?
    public let originalRequest: URLRequest
    public var isValid: Bool
    
    public init(_ clientResponse: ClientResponse, _ factoryResponse: (ClientResponse)throws->T) {
        
        do {
            self.result = .success(try factoryResponse(clientResponse))
            self.isValid = clientResponse.isValid
            
        } catch {
            
            self.result = .failure(clientResponse.error ?? error)
            self.isValid = false
        }
        
        self.urlResponse = clientResponse.urlResponse
        self.originalRequest = clientResponse.originalRequest
    }
}

extension Response.Result where T: Equatable {
    public static func ==(lhs: Response.Result, rhs: Response.Result) -> Bool {
        
        switch (lhs, rhs) {
        case (.success(let lhs), .success(let rhs)): return lhs == rhs
        case (.failure(let lhs), .failure(let rhs)): return type(of: lhs) == type(of: rhs)
        default: return false
        }
    }
}

extension Response where T: Equatable {
    
    public static func ==(lhs: Response, rhs: Response) -> Bool {
        
        return lhs.result == rhs.result
            && lhs.isValid == rhs.isValid
            && lhs.originalRequest == rhs.originalRequest
            && lhs.urlResponse == rhs.urlResponse
    }
}

// MARK: ClientResponse

public struct ClientResponse: Equatable, HasURLResponse {
    
    public let originalRequest: URLRequest
    public var data: AnyData?
    public let urlResponse: URLResponse?
    public var error: Error?
    
    public var isValid: Bool
    
    /// the max data to load into memory from self.data (URL)
    public var maxStreamMemory: Int = 5_000_000
    
    public init(_ originalRequest: URLRequest, _ data: AnyData?, _ urlResponse: URLResponse?, _ error: Error?) {
        
        self.originalRequest = originalRequest
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
        
        self.isValid = data != nil
    }
    
    public init(_ originalRequest: URLRequest, _ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) {
        self.init(originalRequest, data.map { .data($0) }, urlResponse, error)
    }
    
    public init(_ originalRequest: URLRequest, _ url: URL?, _ urlResponse: URLResponse?, _ error: Error?) {
        self.init(originalRequest, url.map { .atURL($0) }, urlResponse, error)
    }
    
    public enum ClientResponseError: Error {
        case noDataOrError
    }
    
    // MARK: get values
    
    public func getResponse() throws -> AnyData {
        
        return try self.data ?? { throw self.error ?? ClientResponseError.noDataOrError }()
    }
    
    public func getData() throws -> Data {
        return try self.getResponse().asData(maxStreamSize: self.maxStreamMemory)
    }
    
    public func json(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        
        return try JSONSerialization.jsonObject(with: self.getData(), options: options)
    }
    
    public func string(encoding: String.Encoding? = nil) throws -> String? {
        
        let encoding = encoding ?? self.httpURLResponse?.httpHeaders.contentType?.encoding ?? .utf8
        return try String(data: self.getData(), encoding: encoding)
    }
    
    public func decodable<T: Decodable>(_: T.Type = T.self, decoder: TopLevelDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(from: self.getData())
    }
    
    public static func ==(lhs: ClientResponse, rhs: ClientResponse) -> Bool {
        
        return lhs.data == rhs.data
            && lhs.urlResponse == rhs.urlResponse
            && (lhs.error == nil) == (rhs.error == nil)
            && lhs.originalRequest == rhs.originalRequest
            && lhs.isValid == rhs.isValid
    }
}


//func tURLResponse(_ v: URLResponse) {
//
//    _ = v.mimeType
//    _ = v.suggestedFilename
//    _ = v.textEncodingName
//    _ = v.url
//
//    let l = v as? HTTPURLResponse
//
//    _ = l?.allHeaderFields
//    _ = l?.statusCode
//}

















