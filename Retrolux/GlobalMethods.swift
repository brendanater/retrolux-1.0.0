//
//  GlobalMethods.swift
//  Retrolux
//
//  Created by Brendan Henderson on 1/5/18.
//  Copyright © 2018 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

/// the default memoryThreshold for Retrolux to load from streams and urls.
public var defaultMemoryThreshold: () -> Int64 = { 20_000_000 }
