//
//  RequestBody.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol RequestBody {
    func requestBody() throws -> Body
}
