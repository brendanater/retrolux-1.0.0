//
//  Response.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public struct Response<T> {
    
    public let originalRequest: URLRequest
    
    public var body: T?
    public let urlResponse: URLResponse?
    public var error: Error?
    public var isValid: Bool
    
    public init(_ originalRequest: URLRequest, _ body: T?, _  urlResponse: URLResponse?, _ error: Error?) {
        
        self.originalRequest = originalRequest
        
        self.body = body
        self.error = error
        self.urlResponse = urlResponse
        
        self.isValid = body != nil
    }
    
    // MARK: Interpret
    
    public enum Interpreted {
        case body(T)
        case error(Error?)
    }
    
    public func interpreted() -> Interpreted {
        return self.body.map { .body($0) } ?? .error(self.error)
    }
    
    public enum NoError: Error {
        case noBodyOrErrorInInterpretedResponse
    }
    
    public func interpret() throws -> T {
        
        switch self.interpreted() {
        case .body(let body): return body
        case .error(let error): throw error ?? NoError.noBodyOrErrorInInterpretedResponse
        }
    }
    
    // map
    
    public func convert<U>(_ f: (Response<T>)throws->U?) -> Response<U> {
        
        var body: U? = nil
        var error: Error? = nil
        
        do {
            body = try f(self)
        } catch let _error {
            error = _error
        }
        
        return Response<U>(self.originalRequest, body, self.urlResponse, self.error ?? error)
    }
    
    // convenience
    
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
}

extension Response where T: Equatable {
    
    public static func ==(lhs: Response, rhs: Response) -> Bool {
        
        return lhs.body == rhs.body
            && (lhs.error == nil) == (rhs.error == nil)
            && lhs.isValid == rhs.isValid
            && lhs.originalRequest == rhs.originalRequest
            && lhs.urlResponse == rhs.urlResponse
    }
}

//// MARK: ClientResponse
//
//public struct ClientResponse: Equatable {
//
//    public let originalRequest: URLRequest
//    public var data: AnyData?
//    public let urlResponse: URLResponse?
//    public var error: Error?
//
//    public var isValid: Bool
//
//    /// the max data to load into memory from self.data (URL)
//    public var maxStreamMemory: Int = 5_000_000
//
//    public init(_ originalRequest: URLRequest, _ data: AnyData?, _ urlResponse: URLResponse?, _ error: Error?) {
//
//        self.originalRequest = originalRequest
//        self.data = data
//        self.urlResponse = urlResponse
//        self.error = error
//
//        self.isValid = data != nil
//    }
//
//    public init(_ originalRequest: URLRequest, _ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) {
//        self.init(originalRequest, data.map { .data($0) }, urlResponse, error)
//    }
//
//    public init(_ originalRequest: URLRequest, _ url: URL?, _ urlResponse: URLResponse?, _ error: Error?) {
//        self.init(originalRequest, url.map { .atURL($0) }, urlResponse, error)
//    }
//
//    // returns a client response with no data, urlResponse, or error
//    public static func empty(_ originalRequest: URLRequest) -> ClientResponse {
//        return ClientResponse(originalRequest, Data?.none, nil, nil)
//    }
//
//    public enum ClientResponseError: Error {
//        case noDataOrError
//    }
//
//    // MARK: get values
//
//    public func getResponse() throws -> AnyData {
//
//        return try self.data ?? { throw self.error ?? ClientResponseError.noDataOrError }()
//    }
//
//    public func getData() throws -> Data {
//        return try self.getResponse().asData(maxStreamSize: self.maxStreamMemory)
//    }
//
////    public func json(options: JSONSerialization.ReadingOptions = []) throws -> Any {
////
////        return try JSONSerialization.jsonObject(with: self.getData(), options: options)
////    }
////
////    public func string(encoding: String.Encoding? = nil) throws -> String? {
////
////        let encoding = encoding ?? self.httpURLResponse?.httpHeaders.contentType?.encoding ?? .utf8
////        return try String(data: self.getData(), encoding: encoding)
////    }
////
////    public func decodable<T: Decodable>(_: T.Type = T.self, decoder: TopLevelDecoder = JSONDecoder()) throws -> T {
////        return try decoder.decode(from: self.getData())
////    }
////
//    public static func ==(lhs: ClientResponse, rhs: ClientResponse) -> Bool {
//
//        return lhs.data == rhs.data
//            && lhs.urlResponse == rhs.urlResponse
//            && (lhs.error == nil) == (rhs.error == nil)
//            && lhs.originalRequest == rhs.originalRequest
//            && lhs.isValid == rhs.isValid
//    }
//
//    public var httpURLResponse: HTTPURLResponse? {
//        return self.urlResponse as? HTTPURLResponse
//    }
//
//    public var statusCode: Int? {
//        return self.httpURLResponse?.statusCode
//    }
//
//    public var mimeType: String? {
//        return self.urlResponse?.mimeType
//    }
//
//    public var allHeaderFields: [String: String]? {
//        return self.httpURLResponse?.allHeaderFields as? [String: String]
//    }
//}


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

















