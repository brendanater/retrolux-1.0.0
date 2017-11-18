//
//  Extensions.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/27/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
    import MobileCoreServices
#elseif os(macOS)
    import CoreServices
#endif

// String.Index

extension String.Index {
    
    public func offset(by index: Int) -> String.Index {
        return String.Index(encodedOffset: self.encodedOffset + index)
    }
}

// DispatchSemaphore

extension DispatchSemaphore {
    
    public class SemaphoreRetrieve<T> {
        
        private let semaphore: DispatchSemaphore
        
        public var response: T? {
            didSet {
                self.semaphore.signal()
            }
        }
        
        public init(_ semaphore: DispatchSemaphore) {
            self.semaphore = semaphore
        }
    }
    
    public static func retrieve<T>(_ value: T.Type = T.self, timeout: DispatchTime? = nil, execute: (SemaphoreRetrieve<T>)throws->()) rethrows -> T? {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let semaphoreRetrieve = SemaphoreRetrieve<T>(semaphore)
        
        try execute(semaphoreRetrieve)
        
        if let timeout = timeout {
            
            _ = semaphore.wait(timeout: timeout)
        } else {
            semaphore.wait()
        }
        
        return semaphoreRetrieve.response
    }
    
}

// InputStream

extension InputStream {
    
    public enum InputStreamGetDataError: Error {
        case inputStreamOverMaxMemorySize
        case inputStreamFailedWithError(Error)
    }
    
    /// streams to Data with maxMemorySize or 20MB. willReset takes the current data before it is emptied and returns an optional new maxMemorySize (nil == throw overMaxMemorySize).
    public func data(maxMemorySize: Int = 20_000_000, willReset resetHandler: ((inout Data)throws->Int?)? = nil) throws -> Data {
        
        var maxMemorySize = maxMemorySize
        var data = Data()
        
        self.open()
        defer { self.close() }
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        
        while self.hasBytesAvailable {
            
            let bytesRead = self.read(&buffer, maxLength: 1024)
            
            if let error = self.streamError {
                throw InputStreamGetDataError.inputStreamFailedWithError(error)
            }
            
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else {
                break
            }
            
            if data.count > maxMemorySize {
                
                if let resetHandler = resetHandler {
                    
                    if let newMaxMemorySize = try resetHandler(&data) {
                        
                        maxMemorySize = newMaxMemorySize
                    }
                    
                    data.removeAll()
                    
                    continue
                } else {
                    throw InputStreamGetDataError.inputStreamOverMaxMemorySize
                }
            }
        }
        
        return data
    }
    
    public func asAnyData(overflowSize: Int = 20_000_000, overflowFile: URL = URL.temporaryFileURL()) throws -> AnyData {
        
        var data: Data = Data()
        var writtenToURL: Bool = false
        
        data = try self.data(maxMemorySize: overflowSize, willReset: {
            
            try $0.write(to: overflowFile)
            
            writtenToURL = true
            
            return nil
        })
        
        if writtenToURL {
            try data.write(to: overflowFile)
            return .atURL(overflowFile)
        } else {
            return .data(data)
        }
    }
}

// sequence


extension Sequence where Self: RangeReplaceableCollection {
    
    mutating func popFirst() -> Element? {
        
        return self.first == nil ? nil : self.removeFirst()
    }
}

extension String {
    
    public mutating func popLast() -> Element? {
        
        return self.last == nil ? nil : self.removeLast()
    }
}

// URL

extension URL {
    
    public var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: self.baseURL != nil)
    }
    
    public var queryItems: [URLQueryItem]? {
        return self.components?.queryItems
    }
    
    public var preferredMimeTypeForPathExtension: String? {
        
        guard
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self.pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        else {
            return nil
        }
        
        return contentType as String
    }
    
    /// returns an unused file URL for the temporary directory and a random filename
    public static func temporaryFileURL() -> URL {
        
        func newURL() -> URL {
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("retrolux_temp_" + UUID().uuidString)
        }
        
        var url = newURL()
        
        var retryCount = 0
        while FileManager.default.fileExists(atPath: url.path) {
            url = newURL()
            if retryCount < 5 {
                retryCount += 1
            } else {
                fatalError("Failed to find an unused temporary file URL")
            }
        }
        
        return url
    }
}

// MARK: URLRequest

extension URLRequest {
    
    public var urlComponents: URLComponents? {
        get {
            return self.url?.components
        }
        set {
            self.url = newValue?.url
        }
    }
    
    public var query: String? {
        get {
            return self.url?.query
        }
        set {
            self.urlComponents?.query = newValue
        }
    }
}

extension NSURLRequest {
    
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
            self.init(rawValue: httpMethod?.uppercased() ?? "GET")
        }
    }
    
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
    
    public typealias HTTPMethod = NSURLRequest.HTTPMethod
    
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

public extension String {
    
    /// adds quotes escaping sub quotes and backslashes
    public var quoted: String {
        
        var result = ""
        
        for c in self {
            switch c {
            case "\"", "\\":
                result.append("\\")
                result.append(c)
            default:
                result.append(c)
            }
        }
        
        return "\"\(result)\""
    }
    
    /// removes quotes unescaping sub quotes and backslashes
    public var unquoted: String? {
        
        guard self.hasPrefix("\"") && self.hasSuffix("\"") else {
            // unquoted
            return nil
        }
        
        var control = self.reversed().dropLast().dropFirst()
        
        var result: String = ""
        
        while !control.isEmpty {
            let c = control.removeLast()
            
            switch c {
                
            case "\\":
                guard !control.isEmpty else {
                    // escaping ending quote
                    return nil
                }
                
                let c = control.removeLast()
                
                switch c {
                case "\\", "\"": result.append(c)
                default:
                    // unescaped backslash
                    return nil
                }
                
                
            case "\"":
                // unescaped quote
                return nil
                
            default: result.append(c)
                
            }
        }
        
        return result
    }
    
}

/// An enum for the default REST httpMethods and statusConfirmations ( (Int)->Bool )
//public enum RestfulHTTPMethod {
//    /// defines httpMethod: "GET"    and statusConfirmation: 200.
//    case list
//    /// defines httpMethod: "POST"   and statusConfirmation: 201.
//    case create
//    /// defines httpMethod: "GET"    and statusConfirmation: 200.
//    case retrieve
//    /// defines httpMethod: "PUT"    and statusConfirmation: 200
//    case update
//    /// defines httpMethod: "PATCH"  and statusConfirmation: 200
//    case partialUpdate
//    /// defines httpMethod: "DELETE" and statusConfirmation: 204.
//    case destroy
//
//    public var httpMethod: String {
//        switch self {
//        case .list, .retrieve: return "GET"
//        case .create: return "POST"
//        case .update: return "PUT"
//        case .partialUpdate: return "PATCH"
//        case .destroy: return "DELETE"
//        }
//    }
//
//    public var statusConfirmation: (Int)->Bool {
//        switch self {
//        case .list, .retrieve, .update, .partialUpdate: return { $0 == 200 }
//        case .create: return { $0 == 201 }
//        case .destroy: return { $0 == 204 }
//        }
//    }
//}

extension NSMutableURLRequest {
    // TODO: uncomment when methods from extensions can be overridden
//    /// Sets the httpMethod of the REST method
//    open func set(restful: RestfulHTTPMethod) {
//        self.httpMethod = restful.httpMethod
//    }
}

extension URLRequest {
    
    /// Sets the httpMethod of the REST method
//    public mutating func set(restful: RestfulHTTPMethod) {
//        self.httpMethod = restful.httpMethod
//    }
}
