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

fileprivate enum FactoryEncoderUnsupportedError: Error {
    case factoryDoesntSupport(Any, FactoryEncoder)
}

extension FactoryEncoder {
    public func unsupported<T>(_ value: T) -> Error {
        return FactoryEncoderUnsupportedError.factoryDoesntSupport(value, self)
    }
}

// decoder

public protocol FactoryDecoder {
    
    func decode<T>(_ response: Response<AnyData>) throws -> T
}

fileprivate enum FactoryDecoderUnsupportedError: Error {
    case factoryDoesntSupport(Any.Type, FactoryDecoder)
}

extension FactoryDecoder {
    public func unsupported(_ type: Any.Type) -> Error {
        return FactoryDecoderUnsupportedError.factoryDoesntSupport(type, self)
    }
}

// extensions

extension Encodable {
    public func encode(with encoder: JSONEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    public init(from data: Data, using decoder: JSONDecoder) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}

extension JSONEncoder: FactoryEncoder {
    
    public func encode<T>(_ value: T) throws -> Body {
        
        guard value is Encodable else {
            throw self.unsupported(value)
        }

        let data = try (value as! Encodable).encode(with: self)

        return Body(.data(data), [.contentType: "application/json", .contentLength: data.count.description])
    }
}

extension JSONDecoder: FactoryDecoder {
    public func decode<T>(_ response: Response<AnyData>) throws -> T {
        
        guard let metaType = T.self as? Decodable.Type, !(metaType == Decodable.self || metaType == Codable.self) else {
            throw self.unsupported(T.self)
        }
        
        return try metaType.init(from: response.interpret().asData(), using: self) as! T
    }
}

extension JSONSerialization: FactoryConverter {
    
    public func encode<T>(_ value: T) throws -> Body {
        
        let data = try JSONSerialization.data(withJSONObject: value)
        
        return Body(.data(data), [.contentType: "application/json", .contentLength: data.count.description])
    }
    
    public func decode<T>(_ response: Response<AnyData>) throws -> T {
        return try JSONSerialization.jsonObject(with: response.interpret().asData(), options: .allowFragments) as? T ?? { throw self.unsupported(T.self) }()
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















