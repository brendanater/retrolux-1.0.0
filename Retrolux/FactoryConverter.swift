//
//  FactoryConverter.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol FactoryConverter: FactoryEncoder, FactoryDecoder {}

public enum FactoryUnsupportedError: Error {
    case factoryDecoderDoesntSupport(Any.Type, FactoryDecoder)
    case factoryEncoderDoesntSupport(Any, FactoryEncoder)
}

// encoder

public protocol FactoryEncoder {
    
    func supports<T>(_ value: T) -> Bool
    
    func encode<T>(_ value: T) throws -> Body
}

public protocol FactoryDecoder {
    
    /// supports, unsupported, or try decode as? T
    func supports<T>(_ value: T.Type) -> Bool?
    
    func decode<T>(_ response: Response<AnyData>) throws -> T
}

extension FactoryEncoder {
    
    public func support<T>(_ value: T) throws {
        guard self.supports(value) else {
            throw self.unsupported(value)
        }
    }
    
    public func unsupported(_ value: Any) -> Error {
        return FactoryUnsupportedError.factoryEncoderDoesntSupport(value, self)
    }
}

extension FactoryDecoder {
    
    public func support<T>(_ value: T.Type) throws {
        if let support = self.supports(T.self) {
            guard support else {
                throw self.unsupported(value)
            }
        }
    }
    
    public func unsupported(_ value: Any.Type) -> Error {
        return FactoryUnsupportedError.factoryDecoderDoesntSupport(value, self)
    }
}

// extensions

extension Encodable {
    fileprivate func __encode(with encoder: JSONEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    fileprivate init(__from data: Data, using decoder: JSONDecoder) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}

extension JSONEncoder: FactoryEncoder {
    
    public func supports<T>(_ value: T) -> Bool {
        return value is Encodable
    }
    
    public func encode<T>(_ value: T) throws -> Body {
        try self.support(value)

        let data = try (value as! Encodable).__encode(with: self)

        return Body(.data(data), [.contentType: "application/json", .contentLength: data.count.description])
    }
}

extension JSONDecoder: FactoryDecoder {
    
    public func supports<T>(_ value: T.Type) -> Bool? {
        return T.self is Decodable.Type && !(T.self == Decodable.self || T.self == Codable.self)
    }
    
    public func decode<T>(_ response: Response<AnyData>) throws -> T {
        try self.support(T.self)
        
        return try (T.self as! Decodable.Type).init(__from: response.data(), using: self) as! T
    }
}

extension JSONSerialization: FactoryConverter {
    
    public func supports<T>(_ value: T.Type) -> Bool? {
        // cannot know supporting from type
        return nil
    }
    
    public func supports<T>(_ value: T) -> Bool {
        return JSONSerialization.isValidJSONObject(value)
    }
    
    public func encode<T>(_ value: T) throws -> Body {
        try self.support(value)
        
        let data = try JSONSerialization.data(withJSONObject: value)
        
        return Body(.data(data), [.contentType: "application/json", .contentLength: data.count.description])
    }
    
    public func decode<T>(_ response: Response<AnyData>) throws -> T {
        
        return try JSONSerialization.jsonObject(with: response.data(), options: .allowFragments) as? T ?? { throw self.unsupported(T.self) }()
    }
}

//// simplifiedCoder
//
//extension FactoryEncoder where Self: TopLevelEncoder {
//
//    public func encode<T>(_ value: T) throws -> Body {
//
//        guard value is Encodable else {
//            throw self.unsupported(value)
//        }
//
//        let data = try (value as! Encodable).encode(with: self as TopLevelEncoder)
//
//        return Body(.data(data), [.contentType: self.contentType, .contentLength: data.count.description])
//    }
//}
//
//extension FactoryDecoder where Self: TopLevelDecoder {
//
//    public func decode<T>(_ response: ClientResponse) throws -> T {
//
//        guard let metaType = T.self as? Decodable.Type, !(T.self == Decodable.self || T.self == Codable.self) else {
//            throw self.unsupported(T.self)
//        }
//
//        return try metaType.init(from: response.getData(), using: self as TopLevelDecoder) as! T
//    }
//}
//
//extension URLEncoder: FactoryEncoder {}
//extension URLDecoder: FactoryDecoder {}
//
//extension URLQuerySerializer: FactoryConverter {
//
//    public func encode<T>(_ value: T) throws -> Body {
//
//        let data = try self.queryData(from: value)
//
//        return Body(.data(data), [.contentType: self.contentType, .contentLength: data.count.description])
//    }
//
//    public func decode<T>(_ response: ClientResponse) throws -> T {
//
//        return try self.object(from: response.getData()) as? T ?? { throw self.unsupported(T.self) }()
//    }
//}















