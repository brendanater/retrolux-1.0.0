//
//  Copyable.swift
//  Retrolux
//
//  Created by Brendan Henderson on 1/12/18.
//  Copyright © 2018 Christopher Bryan Henderson. All rights reserved.
//

import Foundation



public protocol Copyable {
    /// Initialize a new copy using the values of self.  Init copy as! Self if subclass
    init(self copy: Self)
}

extension Copyable {
    public func copy() -> Self {
        return Self.init(self: self)
    }
}
