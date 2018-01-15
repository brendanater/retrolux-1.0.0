//
//  RetroluxError.swift
//  Retrolux
//
//  Created by Brendan Henderson on 1/5/18.
//  Copyright © 2018 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol RetroluxErrorProtocol: Error, CustomStringConvertible, CustomDebugStringConvertible {
    var recovery: String? {get}
    var untypedUserInfo: Any {get}
}

open class RetroluxError: RetroluxErrorProtocol {
    
    open let description: String
    open let untypedUserInfo: Any
    open let underlyingError: Error?
    open let recovery: String?
    
    open var debugDescription: String {
        return "\(type(of: self)): \(self.description.debugDescription), userInfo: \(self.untypedUserInfo)"
            + (self.underlyingError.map { ", underlyingError: \(($0 as CustomDebugStringConvertible).debugDescription)" } ?? "")
            + (self.recovery.map { ", recovery: \($0.debugDescription)" } ?? "")
    }
    
    public init(_ description: String, userInfo untypedUserInfo: Any = (), underlyingError: Error? = nil, recovery: String? = nil) {
        self.description = description
        self.untypedUserInfo = untypedUserInfo
        self.underlyingError = underlyingError
        self.recovery = recovery
    }
}

open class RetypedError<UserInfo>: RetroluxError {
    
    open var userInfo: UserInfo {
        return self.untypedUserInfo as! UserInfo
    }
    
    public init(_ description: String, _ userInfo: UserInfo, underlyingError: Error? = nil, recovery: String? = nil) {
        super.init(description, userInfo: userInfo, underlyingError: underlyingError, recovery: recovery)
    }
}

/// An object for finding RetroluxErrors
public struct Errors {
    private init() {}
}



