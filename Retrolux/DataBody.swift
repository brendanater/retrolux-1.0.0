//
//  DataBody.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/14/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

// DataBody -> seems close
// BodyData -> it's not Body's Data
// RetroluxData -> Too long?
// URLData -> seems like saying its referencing data at URL
// HTTPBody -> HTTPBody locks it to HTTP request/responses
// HTTPData -> ..
// ClientData -> Its not Client's Data
// OverflowData -> like its saying its overflowing
// AnyData -> Too generic, because it's like trying to say that this can encompass all types of Data and the referencing and handling associated with that

// DataBody -> describes that this is a body of data
// RetroluxData -> shows that this is Retrolux's handling of request/response Data

// TODO: find out how Retrofit handles temporary files.

/// represents a body of data in memory or on disk
public enum DataBody {
    case url(URL)
    case data(Data)
}

extension DataBody: Equatable {
    
    public static func ==(lhs: DataBody, rhs: DataBody) -> Bool {
        
        switch (lhs, rhs) {
            
        case (.url(let lhs), .url(let rhs)):
            return lhs == rhs
            
        case (.data(let lhs), .data(let rhs)):
            return lhs == rhs
            
        default:
            return false
        }
    }
}

extension DataBody {
    
//    public init(_ inputStream: InputStream, temporarily isTemporaryFile: Bool = true, memoryThreshold: Int64 = Retrolux.defaultMemoryThreshold()) throws {
//
//        var writtenToURL = false
//        let url = URL.temporaryFileURL()
//
//        do {
//
//            let data = try inputStream.streamData(memoryThreshold: memoryThreshold, willReset: {
//
//                try $0.write(to: url)
//                writtenToURL = true
//
//                return Retrolux.defaultMemoryThreshold()
//            })
//
//            if writtenToURL {
//                try data.write(to: url)
//
//                self = .url(url, temporaryFile: isTemporaryFile)
//            } else {
//                self = .data(data)
//            }
//
//        } catch {
//
//            if writtenToURL {
//                try? FileManager.default.removeItem(at: url)
//            }
//
//            throw error
//        }
//    }
    
    public func contentLength() throws -> Int64 {
        
        switch self {
        case .url(let url): return try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? {fatalError()}()
        case .data(let data): return Int64(data.count)
        }
    }
    
    public func removeIfTemporaryURL() throws {
        try self.urlValue.map { try FileManager.default.removeIfInCurrentTemporary($0) }
    }
    
    public var urlValue: URL? {
        if case .url(let url) = self {
            return url
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
    
    public func asStream() -> InputStream? {
        switch self {
        case .url(let url): return InputStream(url: url)
        case .data(let data): return InputStream(data: data)
        }
    }
    
    public func asData(memoryThreshold: Int64 = Retrolux.defaultMemoryThreshold()) throws -> Data? {
        
        switch self {
            
        case .data(let data):
            return data
            
        case .url(let url):
            return try InputStream(url: url)?.streamData(memoryThreshold: memoryThreshold)
        }
    }
    
    public var isURL: Bool {
        
        if case .url(_) = self {
            return true
        } else {
            return false
        }
    }
}

//extension Errors {
//    public struct URL_ {
//        private init() {}
//
//        open class FailedToGetFileContentLength: RetypedError<URL> {}
//    }
//}
//public protocol VariableKeyProtocol: AnyObject, Hashable {
//    associatedtype Value
//
//    func asValue(_ value: Any?) -> Value?
//}
//
//extension VariableKeyProtocol {
//    public func asValue(_ value: Any?) -> Value? {
//        return value as? Value
//    }
//
//    public static func ==(lhs: Self, rhs: Self) -> Bool {
//        return lhs === rhs
//    }
//}
//
//open class VariableKey<Value>: VariableKeyProtocol {
//
//    public let hashValue: Int = ObjectIdentifier(VariableKey.self).hashValue
//
//    public func asValue(_ value: Any?) -> Value? {
//        return value as? Value
//    }
//}
//
//open class RetroluxError: Error, CustomStringConvertible {
//
//    public let identifier: AnyHashable
//    public let description: String
//    public let userInfo: Any
//    public let underlyingError: Error?
//    public let recovery: String?
//
//    open var debugDescription: String {
//        return "\(type(of: self))"
//            + " (identifier: \(self.identifier)):"
//            + " \(self.description.debugDescription),"
//            + " userInfo: \(self.userInfo)"
//            + (self.underlyingError.map { ", underlyingError: \(type(of: $0)) (\($0))" } ?? "")
//            + (self.recovery.map { ", recovery: \($0.debugDescription)" } ?? "")
//    }
//
//    public init(identifier: AnyHashable, _ description: String, userInfo: Any, underlyingError: Error? = nil, recovery: String? = nil) {
//        self.identifier = identifier
//        self.description = description
//        self.userInfo = userInfo
//        self.underlyingError = underlyingError
//        self.recovery = recovery
//    }
//
//    public init<Key: VariableKeyProtocol>(_ identifier: Key, _ description: String, userInfo: Key.Value, underlyingError: Error? = nil, recovery: String? = nil) {
//        self.identifier = identifier
//        self.description = description
//        self.userInfo = userInfo
//        self.underlyingError = underlyingError
//        self.recovery = recovery
//    }
//
//    public subscript<Key: VariableKeyProtocol>(identifier: Key) -> Key.Value? {
//        return self.info(for: identifier)
//    }
//
//    public func info<T>(for identifier: AnyHashable, _ infoType: T.Type = T.self) -> T? {
//        return self.identifier == identifier ? self.userInfo as? T : nil
//    }
//}
//
//public struct Errors {
//    private init() {}
//}
//
//extension Errors {
//    public struct Testing {
//        private init() {}
//        public static let testRun = VariableKey<Int>()
//    }
//}
//
//do {
//
//    //    throw RetroluxError(Errors.Testing.testRun, "Test run with VariableKey.", userInfo: .max)
//    throw RetroluxError(Errors.Testing.testRun, "Test", userInfo: .min, underlyingError: RetroluxError.init(identifier: "test", "a test.", userInfo: "test info"), recovery: "remove this test.")
//
//} catch let error as RetroluxError {
//
//    if let testRunNumber = error[Errors.Testing.testRun] {
//        print("testRunNumber:", testRunNumber)
//    } else if let testRunString = error.info(for: Errors.Testing.testRun) as String? {
//        print("testRunString:", testRunString)
//    }
//
//    switch error.userInfo {
//    case let number as Int:
//        if error.identifier == Errors.Testing.testRun as AnyHashable {
//
//        }
//    default:
//        print(error.userInfo, "is not a number.")
//    }
//
//    print(error)
//    print(error.debugDescription)
//
//} catch {
//    print(error)
//}

extension FileManager {
    
    public func inCurrentTemporary(_ url: URL) throws -> Bool {
        
        var urlRelationship: FileManager.URLRelationship = .contains
        
        try self.getRelationship(&urlRelationship, ofDirectoryAt: self.temporaryDirectory, toItemAt: url)
        
        return urlRelationship == .contains
    }
    
    public func removeIfInCurrentTemporary(_ url: URL) throws {
        if try self.inCurrentTemporary(url) {
            try self.removeItem(at: url)
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



