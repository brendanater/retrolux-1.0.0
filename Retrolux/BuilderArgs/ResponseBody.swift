//
//  ResponseBody.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/16/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol ResponseBody {
    init(from response: Response<AnyData>) throws
}
