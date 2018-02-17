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

// URLQueryItem

extension URLQueryItem {

    public init(_ name: String, _ value: String?) {
        self.init(name: name, value: value)
    }
}

// DispatchSemaphore

extension DispatchSemaphore {
    
    open class SemaphoreRetrieve<T> {
        
        fileprivate let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        
        public init() {}
        
        open var response: T? {
            didSet {
                self.semaphore.signal()
            }
        }
        
        open func wait(timeout: DispatchTime) -> T? {
            _ = self.semaphore.wait(timeout: timeout)
            return self.response
        }
        
        open func wait() -> T {
            self.semaphore.wait()
            return self.response!
        }
    }
    
    public static func retrieve<T>(_ value: T.Type = T.self, timeout: DispatchTime, execute: (SemaphoreRetrieve<T>)throws->()) rethrows -> T? {
        let s = SemaphoreRetrieve<T>()
        try execute(s)
        return s.wait(timeout: timeout)
    }
    
    public static func retrieve<T>(_ value: T.Type = T.self, execute: (SemaphoreRetrieve<T>)throws->()) rethrows -> T {
        let s = SemaphoreRetrieve<T>()
        try execute(s)
        return s.wait()
    }
}

// InputStream

extension Errors {
    public struct InputStream_ {
        private init() {}
        
        open class FailedToInitStreamForURL: RetypedError<URL> {}
        
        open class FailedToStreamData: RetypedError<FTSDErrorCase> {}
        public enum FTSDErrorCase {
            case overflowedMemoryThreshold
            case streamError
        }
    }
}

extension InputStream {
    
    public static func stream(for url: URL) throws -> InputStream {
        
        return try InputStream(url: url) ?? { throw Errors.InputStream_.FailedToInitStreamForURL("Failed to init InputStream for url: \(url)", url) }()
    }
    
    /// streams to Data with memoryThreshold (defaulting to Retrolux.defaultMemoryThreshold).  When data.count > memoryThreshold, data is passed to willReset and then emptied.  If there is no handler, willReset defaults to throwing.
    public func streamData(memoryThreshold: Int64 = Retrolux.defaultMemoryThreshold(), willReset resetHandler: (inout Data) throws -> Int64? = { _ in throw Errors.InputStream_.FailedToStreamData("InputStream data input overflowed memoryThreshold", .overflowedMemoryThreshold) }) throws -> Data {
        
        var memoryThreshold = memoryThreshold
        var data = Data()
        
        self.open()
        defer { self.close() }
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        
        while self.hasBytesAvailable {
            
            let bytesRead = self.read(&buffer, maxLength: 1024)
            
            if let error = self.streamError {
                throw Errors.InputStream_.FailedToStreamData("\(type(of: self)) failed to get data with error", .streamError, underlyingError: error)
            }
            
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else {
                break
            }
            
            if data.count > memoryThreshold {
                
                if let newMemoryThreshold = try resetHandler(&data) {
                    
                    memoryThreshold = newMemoryThreshold
                }
                
                data.removeAll()
            }
        }
        
        return data
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
            return FileManager.default.temporaryDirectory.appendingPathComponent("retrolux_temp_" + UUID().uuidString)
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
    
    /// returns whether httpBody != nil || httpBodyStream != nil
    public var isHTTPBodySet: Bool {
        return self.httpBody != nil || self.httpBodyStream != nil
    }
}

// String

public extension String {
    
    func ranges(of stringToFind: String) -> [Range<String.Index>] {
        assert(!stringToFind.isEmpty, "Cannot find ranges of empty string")
        var searchRange: Range<String.Index>?
        var ranges: [Range<String.Index>] = []
        while let foundRange = self.range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: self.endIndex))
            ranges.append(foundRange)
        }
        return ranges
    }
    
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var searchRange: Range<String.Index>?
        var count = 0
        while let foundRange = self.range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: self.endIndex))
            count += 1
        }
        return count
    }
    
    public mutating func format(_ args: [CVarArg]) {
        self = self.appendingFormat("", args)
    }
    
    /// adds quotes escaping sub quotes and backslashes
    public var quoted: String {
        
        var result = ""
        
        for c in self {
            switch c {
            case "\"", "\\":
                result.append("\\")
            default:
                break
            }
            result.append(c)
        }
        
        return "\"\(result)\""
    }
    
    /// removes quotes unescaping sub quotes and backslashes.  Ignores controls. (e.g. '\n', '\r')
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
        case "SHIFT_JIS"    : self = .shiftJIS
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
