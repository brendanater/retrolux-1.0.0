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


// String.Encoding

extension String.Encoding {
    
    /// for HTTP header charset e.g. "; charset=UTF-8"
    public var charset: String? {
        switch self {  // nil == couldn't find
        case .ascii:            return "US-ASCII" // https://en.wikipedia.org/wiki/ASCII "ASCII"
        case .iso2022JP:        return "ISO-2022-JP"
        case .isoLatin1:        return "ISO-8859-1"
        case .isoLatin2:        return "ISO-8859-2"
        case .japaneseEUC:      return "EUC-JP"
        case .macOSRoman:       return "macintosh" // https://en.wikipedia.org/wiki/Mac_OS_Roman JAVA: "MacRoman"
        case .nextstep:         return nil
        case .nonLossyASCII:    return nil
        case .shiftJIS:         return "Shift_JIS"
        case .symbol:           return nil
        case .utf8:             return "UTF-8"
        case .unicode:          return "UTF-16"
        case .utf16:            return "UTF-16"
        case .utf16BigEndian:   return "UTF-16BE"
        case .utf16LittleEndian:return "UTF-16LE"
        case .utf32:            return "UTF-32"
        case .utf32BigEndian:   return "UTF-32BE"
        case .utf32LittleEndian:return "UTF-32LE"
        case .windowsCP1250:    return nil
        case .windowsCP1251:    return nil
        case .windowsCP1252:    return "windows-1252"
        case .windowsCP1253:    return nil
        case .windowsCP1254:    return nil
        default: return nil
        }
    }
    
    
    public init?(charset: String) {
        
        switch charset.uppercased() {
        case "US-ASCII"     : self = .ascii
        case "ISO-2022-JP"  : self = .iso2022JP
        case "ISO-8859-1"   : self = .isoLatin1
        case "ISO-8859-2"   : self = .isoLatin2
        case "EUC-JP"       : self = .japaneseEUC
        case "SHIFT_JIS"    : self = .shiftJIS // "Shift_JIS"
        case "UTF-8"        : self = .utf8
        case "UTF-16"       : self = .utf16
        case "UTF-16BE"     : self = .utf16BigEndian
        case "UTF-16LE"     : self = .utf16LittleEndian
        case "UTF-32"       : self = .utf32
        case "UTF-32BE"     : self = .utf32BigEndian
        case "UTF-32LE"     : self = .utf32LittleEndian
            
        case "ASCII"        : self = .ascii // IANA deprecated
        case "ANSI"         : self = .windowsCP1252 // common mislabel
        case "MACROMAN"     : self = .macOSRoman // java "MacRoman"
        default:
            switch charset.lowercased() {
            case "macintosh"    : self = .macOSRoman
            case "windows-1252" : self = .windowsCP1252
            default: return nil
            }
        }
    }
}
