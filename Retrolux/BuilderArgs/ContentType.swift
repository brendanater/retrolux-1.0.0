//
//  ContentType.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/6/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

extension HTTPHeaders {
    
    /// header field: "Content-Type" defined in https://www.ietf.org/rfc/rfc2045.txt#section-5.1
    public var contentType: ContentType? {
        get {
            return ContentType(self[.contentType])
        }
        set {
            self[.contentType] = newValue?.description
        }
    }
    
    @discardableResult
    public mutating func set(contentType: ContentType) -> HTTPHeaders {
        self.contentType = contentType
        return self
    }
}

/// header field: "Content-Type" defined in https://www.ietf.org/rfc/rfc2045.txt#section-5.1
public struct ContentType: HTTPHeaderProtocol {
    
    public static var field: HTTPHeaders.Field {
        return .contentType
    }
    
    public var description: String {
        
        let parameters: String = self.parameters.map {
            
            if ContentType.isToken($0.value) {
                return "\($0.key)=\($0.value)"
            } else {
                return "\($0.key)=\($0.value.quoted)"
            }
            
            }.joined(separator: "; ")
        
        return self.mimeType + (parameters.isEmpty ? "" : "; " + parameters)
    }
    
    public var type: TypeToken
    public var subType: SubTypeToken
    
    public var parameters: [ParameterToken: String]
    
    /// the mimeType: type "/" subType
    public var mimeType: String {
        return "\(self.type)/\(self.subType)"
    }
    
    /// setting the mimeType basically overrides the entire description of the value
    public func with(mimeType: String) -> ContentType? {
        
        guard let (type, subType) = ContentType.separateTypes(mimeType) else {
            return nil
        }
        
        return ContentType(type, subType, self.parameters)
    }
    
    public init(_ type: TypeToken, _ subType: SubTypeToken, _ parameters: [ParameterToken: String] = [:]) {
        
        self.type = type
        self.subType = subType
        self.parameters = parameters
    }
    
    public init?(_ value: String?) {
        guard var value = value else {
            return nil
        }
        
        // get type
        
        func getValue<T: RawRepresentable>(to character: Character) -> T? where T.RawValue == String {
            return T(rawValue: value.remove(to: character.description, removeDestinationIfPresent: true).trimmingWhitespace())
        }
        
        guard let type = getValue(to: "/") as TypeToken? else {
            return nil
        }
        
        self.type = type
        
        // get subType
        
        guard let subType = getValue(to: ";") as SubTypeToken? else {
            return nil
        }
        
        self.subType = subType
        
        // get parameters
        
        self.parameters = [:]
        
        while !value.isEmpty {
            
            guard let parameter = getValue(to: "=") as ParameterToken? else {
                return nil
            }
            
            var result = ""
            
            // value can have ";" if in quotes
            while !value.isEmpty {
                
                result += value.remove(to: ";", removeDestinationIfPresent: true)
                
                let trimmed = result.trimmingWhitespace()
                
                if ContentType.isToken(trimmed) {
                    result = trimmed
                    break
                    
                } else if let trimmed = trimmed.unquoted {
                    result = trimmed
                    break
                    
                } else {
                    result.append(";")
                }
            }
            
            guard !result.isEmpty else {
                // no value
                return nil
            }
            
            self.parameters[parameter] = result
        }
    }
    
    public static func separateTypes(_ mimeType: String?) -> (type: TypeToken, subType: SubTypeToken)? {
        guard var mimeType = mimeType else {
            return nil
        }
        
        var type: String = ""
        var subType: String = ""
        
        while !mimeType.isEmpty {
            let c = mimeType.removeFirst()
            if c == "/" {
                break
            }
            type.append(c)
        }
        while !mimeType.isEmpty {
            subType.append(mimeType.removeFirst())
        }
        
        if let type = TypeToken(rawValue: type),
            let subType = SubTypeToken(rawValue: subType) {
            
            return (type, subType)
        } else {
            return nil
        }
    }
    
    public static let tokenCharacters: [Character] = {
        
        return (33...126)
            .map { UnicodeScalar($0)!.description.first! }
            .filter { [
                "(", ")", "<", ">", "@",
                ",", ";", ":", "\\", "\"",
                "/", "[", "]", "?", "="
                ].contains($0) == false }
    }()
    
    public static func isToken(_ value: String) -> Bool {
        
        // not value has an invalid character or ascii doesn't contain the character
        return !value.isEmpty && !value.contains(where: { !tokenCharacters.contains($0) })
    }
    
    public struct TypeToken: RawRepresentable, CustomStringConvertible {
        
        public let rawValue: String
        
        public init?(rawValue: String) {
            
            guard ContentType.isToken(rawValue) else {
                return nil
            }
            
            self.rawValue = rawValue
        }
        
        public init?(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        public var description: String {
            return self.rawValue
        }
        
        public static let application   : TypeToken = TypeToken(rawValue: "application")!
        public static let audio         : TypeToken = TypeToken(rawValue: "audio      ")!
        public static let font          : TypeToken = TypeToken(rawValue: "font       ")!
        public static let example       : TypeToken = TypeToken(rawValue: "example    ")!
        public static let image         : TypeToken = TypeToken(rawValue: "image      ")!
        public static let message       : TypeToken = TypeToken(rawValue: "message    ")!
        public static let model         : TypeToken = TypeToken(rawValue: "model      ")!
        public static let multipart     : TypeToken = TypeToken(rawValue: "multipart  ")!
        public static let text          : TypeToken = TypeToken(rawValue: "text       ")!
        public static let video         : TypeToken = TypeToken(rawValue: "video      ")!
    }
    
    public struct SubTypeToken: RawRepresentable, CustomStringConvertible {
        
        public let rawValue: String
        
        public init?(rawValue: String) {
            
            guard ContentType.isToken(rawValue) else {
                return nil
            }
            
            self.rawValue = rawValue
        }
        
        public init?(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        public var description: String {
            return self.rawValue
        }
        
        public static let json              : SubTypeToken = SubTypeToken(rawValue: "json")!
        /// "form-data"
        public static let formData          : SubTypeToken = SubTypeToken(rawValue: "form-data")!
        public static let mixed             : SubTypeToken = SubTypeToken(rawValue: "mixed")!
        /// "x-www-form-urlencoded"
        public static let xWWWFormUrlencoded: SubTypeToken = SubTypeToken(rawValue: "x-www-form-urlencoded")!
        public static let plain             : SubTypeToken = SubTypeToken(rawValue: "plain")!
        public static let octetStream       : SubTypeToken = SubTypeToken(rawValue: "octet-stream")!
    }
    
    public struct ParameterToken: RawRepresentable, Hashable, CustomStringConvertible {
        
        public let rawValue: String
        
        public init?(rawValue: String) {
            
            guard ContentType.isToken(rawValue) else {
                return nil
            }
            
            self.rawValue = rawValue
        }
        
        public var description: String {
            return self.rawValue
        }
        
        public var hashValue: Int {
            return self.rawValue.lowercased().hashValue
        }
        
        public static func ==(lhs: ParameterToken, rhs: ParameterToken) -> Bool {
            return lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
        }
        
        public static let charset   : ParameterToken = ParameterToken(rawValue: "charset")!
        public static let boundary  : ParameterToken = ParameterToken(rawValue: "boundary")!
    }
}

extension ContentType {
    
    /// parameter: "charset"
    public var charset: String? {
        get {
            return self.parameters[.charset]
        }
        set {
            self.parameters[.charset] = newValue
        }
    }
    
    /// parameter: "boundary" rfc: https://tools.ietf.org/html/rfc2046#section-5.1.1
    public var boundary: String? {
        get {
            return self.parameters[.boundary]
        }
        set {
            self.parameters[.boundary] = newValue
        }
    }
    
    /// parses the charset parameter to try to guess the encoding to use
    public var encoding: String.Encoding? {
        get {
            return self.charset.flatMap { String.Encoding(charset: $0) }
        }
        set {
            self.charset = newValue?.charset
        }
    }
    
    /// mimeType.lowercased() == "application/json"
    public var isApplicationJSON: Bool                  { return self.type == .application  && self.subType == .json }
    /// mimeType.lowercased() == "application/x-www-form-urlencoded"
    public var isApplicationXWWWFormURLEncoded: Bool    { return self.type == .application  && self.subType == .xWWWFormUrlencoded }
    /// mimeType.lowercased() == "multipart/form-data"
    public var isMultipartFormData: Bool                { return self.type == .multipart    && self.subType == .formData }
    /// mimeType.lowercased() == "multipart/mixed"
    public var isMultipartMixed: Bool                   { return self.type == .multipart    && self.subType == .mixed }
    
    /// ContentType: application/json
    public static let applicationJSON: ContentType = {
        return ContentType(.application, .json)
    }()
    
    /// ContentType: application/x-www-form-urlencoded + Optional("; charset=#{charset}")
    public static func applicationXWWWFormURLEncoded(charset: String? = nil) -> ContentType {
        var header = ContentType(.application, .xWWWFormUrlencoded)
        header.charset = charset
        return header
    }
    
    /// ContentType: multipart/form-data; boundary=#{boundary}
    public static func multipartFormData(boundary: String) -> ContentType {
        return ContentType(.multipart, .formData, [.boundary: boundary])
    }
    
    /// ContentType: multipart/mixed; boundary=#{boundary}
    public static func multipartMixed(boundary: String) -> ContentType {
        return ContentType(.multipart, .mixed, [.boundary: boundary])
    }
    
    public static func textPlain(charset: String = "US-ASCII") -> ContentType {
        var header = ContentType(.text, .plain)
        header.charset = charset
        return header
    }
    
    public var applicationOctetStream: ContentType {
        return ContentType(.application, .octetStream)
    }
}

// MARK: String control

extension String {
    
    /// removes the spaces on both sides of the string
    func trimmingWhitespace() -> String {
        var string = self
        while string.hasPrefix(" ") {
            string.removeFirst()
        }
        while string.hasSuffix(" ") {
            string.removeLast()
        }
        return string
    }
    
    /// adds quotes escaping sub quotes and backslashes
    var quoted: String {
        
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
    var unquoted: String? {
        
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
    
    /// returns the string to the first instance of the destination or returns self.
    mutating func remove<T: StringProtocol>(to destination: T, removeDestinationIfPresent: Bool = false) -> String {
        
        let component = self.components(separatedBy: destination).first!
        
        self.removeSubrange(self.startIndex..<component.endIndex)
        
        if removeDestinationIfPresent, let range = self.range(of: destination) {
            self.removeSubrange(range)
        }
        
        return component
    }
}
