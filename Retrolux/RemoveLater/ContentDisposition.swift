//
//  ContentDisposition.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/16/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


//extension HTTPHeaders {
//
//    /// sets self[.contentDisposition] type and parameters.  See rfc: https://tools.ietf.org/html/rfc6266#section-4.1 (value is always a quoted-string or percent encoded)
//    public mutating func setContentDisposition(_ type: ContentDispositionType, _ parameters: [String: ContentDispositionParameterValue] = [:]) {
//        self[.contentDisposition] = "\(type)" + (parameters.isEmpty ? "" : "; " + parameters.map { "\(($0.value.isExtended ? $0.key : $0.key + "*"))=\($0.value)" }.joined(separator: "; "))
//    }
//}
//
//public struct ContentDispositionType: ExpressibleByStringLiteral, CustomStringConvertible, Equatable {
//
//    public var description: String
//
//    public init(stringLiteral value: String) {
//        self.description = value
//    }
//
//    public static func ==(lhs: ContentDispositionType, rhs: ContentDispositionType) -> Bool {
//        return lhs.description == rhs.description
//    }
//
//    public static let inline    : ContentDispositionType = "inline"
//    public static let attachment: ContentDispositionType = "attachment"
//    public static let formData  : ContentDispositionType = "form-data"
//}
//
//public struct ContentDispositionParameterValue: ExpressibleByStringLiteral, CustomStringConvertible, Equatable {
//
//    public var value: String
//
//    public var extendedValues: (charset: String, language: String?)?
//
//    public var isExtended: Bool {
//        return self.extendedValues != nil
//    }
//
//    public init(_ value: String, extendedValues: (charset: String, language: String?)? = nil) {
//        self.value = value
//        self.extendedValues = extendedValues
//    }
//
//    public init(stringLiteral value: String) {
//        self.value = value
//    }
//
//    public static func ==(lhs: ContentDispositionParameterValue, rhs: ContentDispositionParameterValue) -> Bool {
//        return lhs.description == rhs.description
//    }
//
//    public static var percentEncodingAllowedCharacters: CharacterSet {
//
//        let characters: [Character] = ((30...39).map {$0} // digits
//            + (65...90).map {$0} // uppercase Alpha
//            + (61...122).map {$0} // lowercase Alpha
//            ).map { UnicodeScalar($0)!.description.first! }
//            + ["!", "#", "$", "&", "+", "-", ".", "^", "_", "`", "|", "~"]
//
//        return CharacterSet(charactersIn: String(characters))
//    }
//
//    public var description: String {
//
//        if let (charset, language) = self.extendedValues {
//            return "\(charset)'\(language ?? "")'\(self.value.addingPercentEncoding(withAllowedCharacters: ContentDispositionParameterValue.percentEncodingAllowedCharacters)!)"
//        } else {
//            return self.value.quoted
//        }
//    }
//}

