//
//  Copyable.swift
//  Retrolux
//
//  Created by Brendan Henderson on 1/12/18.
//  Copyright © 2018 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


public protocol Copyable {
    init(copy: Self)
}

extension Copyable {
    public func copy() -> Self {
        return Self(copy: self)
    }
}
