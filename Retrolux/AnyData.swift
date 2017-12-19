//
//  AnyData.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/14/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

/*
 the problems for data:
 1. request input stream has no callback
 2. temporary file will need to be removed later and could potentially remove it too soon or not at all.
 3. always writing to a file first is too slow.
 4. only data may be too large for memory
 */

public enum AnyData {
    
    case url(URL, temporary: Bool)
    case data(Data)
    
    public enum AnyDataError: Error {

        public enum InvalidURLReason {
            case cannotGetInputStream
            case cannotGetContentLength
        }

        case invalidURL(URL, reason: InvalidURLReason)
    }

    public func contentLength() throws -> Int64 {
        switch self {
        case .url(let url, temporary: _): return try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? { throw AnyDataError.invalidURL(url, reason: .cannotGetContentLength) }()
        case .data(let data): return Int64(data.count)
        }
    }

    public func stream() throws -> InputStream {
        switch self {
        case .url(let url, temporary: _): return try InputStream(url: url) ?? { throw AnyDataError.invalidURL(url, reason: .cannotGetInputStream) }()
        case .data(let data): return InputStream(data: data)
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

extension AnyData: Equatable {
    
    public static func ==(lhs: AnyData, rhs: AnyData) -> Bool {
        switch (lhs, rhs) {
        // having the same url, but different temporaries is wierd, so isTemporary is ignored
        case (.url(let lhs, _), .url(let rhs, _)):
            return lhs == rhs
        case (.data(let lhs), .data(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension URL {
    
    /// tries to remove the file at the url if the file is temporary
    public func removeFile(ifTemporary: Bool) throws {
        if ifTemporary {
            try FileManager.default.removeItem(at: self)
        }
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



