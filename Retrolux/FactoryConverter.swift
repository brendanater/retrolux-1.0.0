//
//  FactoryConverter.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol FactoryConverter: FactoryEncoder, FactoryDecoder {}

// encoder

public protocol FactoryEncoder {
    
    func encode<T>(_ value: T) throws -> Body
}

public enum FactoryEncoderUnsupportedError: Error {
    case factoryDoesntSupport(Any, FactoryEncoder)
}

extension FactoryEncoder {
    public func unsupported<T>(_ value: T) -> FactoryEncoderUnsupportedError {
        return FactoryEncoderUnsupportedError.factoryDoesntSupport(value, self)
    }
}

extension FactoryEncoder where Self: TopLevelEncoder {
    
    public func encode<T>(_ value: T) throws -> Body {
        
        guard value is Encodable else {
            throw self.unsupported(value)
        }
        
        let data = try (value as! Encodable).encode(with: self as TopLevelEncoder)
        
        return Body(.data(data), [.contentType: self.contentType, .contentLength: data.count.description])
    }
}

// decoder

public protocol FactoryDecoder {
    
    func decode<T>(_ response: ClientResponse) throws -> T
}

public enum FactoryDecoderUnsupportedError: Error {
    case factoryDoesntSupport(Any.Type, FactoryDecoder)
}

extension FactoryDecoder {
    public func unsupported(_ type: Any.Type) -> FactoryDecoderUnsupportedError {
        return FactoryDecoderUnsupportedError.factoryDoesntSupport(type, self)
    }
}

extension FactoryDecoder where Self: TopLevelDecoder {
    
    public func decode<T>(_ response: ClientResponse) throws -> T {
        
        guard let metaType = T.self as? Decodable.Type, !(T.self == Decodable.self || T.self == Codable.self) else {
            throw self.unsupported(T.self)
        }
        
        return try metaType.init(from: response.getData(), using: self as TopLevelDecoder) as! T
    }
}

// extensions

extension JSONEncoder: FactoryEncoder {}
extension JSONDecoder: FactoryDecoder {}

extension URLEncoder: FactoryEncoder {}
extension URLDecoder: FactoryDecoder {}

extension URLQuerySerializer: FactoryConverter {
    
    public func encode<T>(_ value: T) throws -> Body {
        
        let data = try self.queryData(from: value)
        
        return Body(.data(data), [.contentType: self.contentType, .contentLength: data.count.description])
    }
    
    public func decode<T>(_ response: ClientResponse) throws -> T {
        
        return try self.object(from: response.getData()) as? T ?? { throw self.unsupported(T.self) }()
    }
}

extension JSONSerialization: FactoryConverter {
    
    public func encode<T>(_ value: T) throws -> Body {
        
        let data = try JSONSerialization.data(withJSONObject: value)
        
        return Body(.data(data), [.contentType: JSONSerialization.contentType, .contentLength: data.count.description])
    }
    
    public func decode<T>(_ response: ClientResponse) throws -> T {
        return try JSONSerialization.jsonObject(with: response.getData(), options: .allowFragments) as? T ?? { throw self.unsupported(T.self) }()
    }
}















