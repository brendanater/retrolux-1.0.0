//
//  AnyData.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/14/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


public enum AnyData {
    
    case url(URL, temporary: Bool)
    case data(Data)
}

extension AnyData: Equatable {
    
    public static func ==(lhs: AnyData, rhs: AnyData) -> Bool {
        switch (lhs, rhs) {
        // if urls the same, different temporary values are ignored
        case (.url(let lhs, _), .url(let rhs, _)):
            return lhs == rhs
        case (.data(let lhs), .data(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension AnyData {
    
    public func contentLength() throws -> Int64 {
        switch self {
        case .url(let url, temporary: _): return try url.fileContentLength()
        case .data(let data): return Int64(data.count)
        }
    }
    
    public func removeIfTemporaryURL() throws {
        if case .url(let url, temporary: let isTemporary) = self, isTemporary {
            try url.removeFile(ifTemporary: isTemporary)
        }
    }
    
    /// Inits InputStream with self.  Remember to remove file if temporary.
    private func stream() throws -> InputStream {
        switch self {
        case .url(let url, temporary: _): return try InputStream.stream(for: url)
        case .data(let data): return InputStream(data: data)
        }
    }
    
    public var urlValue: (url: URL, isTemporary: Bool)? {
        if case .url(let url, temporary: let isTemporary) = self {
            return (url, isTemporary)
        } else {
            return nil
        }
    }
    
    public var dataValue: Data? {
        if case .data(let data) = self {
            return data
        } else {
            return nil
        }
    }
    
    public func loadData(memoryThreshold: Int64 = Retrolux.defaultMemoryThreshold()) throws -> Data {
        
        switch self {
            
        case .data(let data):
            return data
            
        case .url(_, _):
            
            let data = try self.stream().streamData(memoryThreshold: memoryThreshold)
            
            try? self.removeIfTemporaryURL()
            
            return data
        }
    }
    
    public var isURL: Bool {
        if case .url(_, _) = self {
            return true
        } else {
            return false
        }
    }
}

extension Errors {
    public struct URL_ {
        private init() {}
        
        open class FailedToGetFileContentLength: RetypedError<URL> {}
    }
}

extension URL {
    
    /// tries to remove the file at the url if temporary
    public func removeFile(ifTemporary: Bool) throws {
        if ifTemporary {
            try FileManager.default.removeItem(at: self)
        }
    }
    
    /// tries to get the contentLength for the local file at url
    public func fileContentLength() throws -> Int64 {
        return try FileManager.default.attributesOfItem(atPath: self.path)[.size] as? Int64 ?? { throw Errors.URL_.FailedToGetFileContentLength("Failed to get file content length for url: \(self)", self) }()
    }
}


//open class ManagedURL: Equatable {
//
//    open let managed: URL
//
//    public required init(_ managed: URL) {
//        self.managed = managed
//    }
//
//    open static func ==(lhs: ManagedURL, rhs: ManagedURL) -> Bool {
//        return lhs.managed == rhs.managed
//    }
//
//    @discardableResult
//    open func extendLife() -> Self {
//        return self
//    }
//
//    deinit {
//        try? FileManager.default.removeItem(at: self.managed)
//    }
//}
//
//public enum AnyData: Equatable {
//
//    case url(URL, temporary: Bool)
//    case data(Data)
//
//    public init(_ data: Data) {
//        self = .data(data)
//    }
//
//    public init(_ url: URL, temporary: Bool) {
//        self = (temporary ? .temporaryURL(ManagedURL(url)) : .url(url))
//    }
//
//    public init(_ stream: InputStream, overflowSize: Int, overflowFile: URL = URL.temporaryFileURL()) throws {
//
//        var data: Data = Data()
//        var writtenToURL: Bool = false
//
//        data = try stream.data(maxMemorySize: overflowSize, willReset: {
//
//            try $0.write(to: overflowFile)
//            writtenToURL = true
//            return nil
//        })
//
//        if writtenToURL {
//            try data.write(to: overflowFile)
//            self = .temporaryURL(ManagedURL(overflowFile))
//        } else {
//            self = .data(data)
//        }
//    }
//
//    public init?(_ request: URLRequest) throws {
//        self = try request.httpBody.map { .data($0) } ?? request.httpBodyStream.map { try AnyData($0) }
//    }
//
//
//
//    public var url: URL? {
//        if case .atURL(let url) = self {
//            return url
//        } else {
//            return nil
//        }
//    }
//
//    public var data: Data? {
//        if case .data(let data) = self {
//            return data
//        } else {
//            return nil
//        }
//    }
//
//    public func asURL() throws -> URL {
//
//        switch self {
//        case .atURL(let url): return url
//        case .data(let data):
//            let url = URL.temporaryFileURL()
//            try data.write(to: url)
//            return url
//        }
//    }
//
//    public func asData(maxStreamSize: Int = 5_000_000) throws -> Data {
//
//        switch self {
//
//        case .atURL(_):
//            return try self.stream().data(maxMemorySize: maxStreamSize)
//
//        case .data(let data):
//
//            return data
//        }
//    }
//
//    public static func ==(lhs: AnyData, rhs: AnyData) -> Bool {
//        switch (lhs, rhs) {
//        case (.atURL(let lhs), .atURL(let rhs)): return lhs == rhs
//        case (.data(let lhs), .data(let rhs)): return lhs == rhs
//        default: return false
//        }
//    }
//}



