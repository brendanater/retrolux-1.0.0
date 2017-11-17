//
//  AnyData.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/14/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public enum AnyData: Equatable {
    
    case atURL(URL)
    case data(Data)
    
    public init(_ data: Data) {
        self = .data(data)
    }
    
    public init(_ atURL: URL) {
        self = .atURL(atURL)
    }
    
    public init(_ stream: InputStream, maxDataMemory: Int = 5_000_000) throws {
        self = try stream.asAnyData(overflowSize: maxDataMemory)
    }
    
    public enum AnyDataError: Error {
        
        public enum InvalidURLReason {
            case failedToGetInputStream
            case cannotGetContentLength
        }
        
        case invalidURL(URL, reason: InvalidURLReason)
    }
    
    public func contentLength() throws -> Int {
        switch self {
        case .atURL(let url): return try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? { throw AnyDataError.invalidURL(url, reason: .cannotGetContentLength) }()
        case .data(let data): return data.count
        }
    }
    
    public func stream() throws -> InputStream {
        switch self {
        case .atURL(let url): return try InputStream(url: url) ?? { throw AnyDataError.invalidURL(url, reason: .failedToGetInputStream) }()
        case .data(let data): return InputStream(data: data)
        }
    }
    
    public var urlValue: URL? {
        if case .atURL(let url) = self {
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
    
    public func asURL() throws -> URL {
        
        switch self {
        case .atURL(let url): return url
        case .data(let data):
            let url = URL.temporaryFileURL()
            try data.write(to: url)
            return url
        }
    }
    
    public func asData(maxStreamSize: Int = 5_000_000) throws -> Data {
        
        switch self {
            
        case .atURL(_):
            return try self.stream().data(maxMemorySize: maxStreamSize)
            
        case .data(let data):
            
            return data
        }
    }
    
    public static func ==(lhs: AnyData, rhs: AnyData) -> Bool {
        switch (lhs, rhs) {
        case (.atURL(let lhs), .atURL(let rhs)): return lhs == rhs
        case (.data(let lhs), .data(let rhs)): return lhs == rhs
        default: return false
        }
    }
}



