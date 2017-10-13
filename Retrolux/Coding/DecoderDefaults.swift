//
//  DecoderDefaults.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/2/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

struct DecoderDefaultKeyedContainer<K: CodingKey>: DecoderKeyedContainer {
    
    typealias Key = K
    
    var decoder: AnyDecoderBase
    var container: DecoderKeyedContainerContainer
    var nestedPath: [CodingKey]
    
    init(decoder: AnyDecoderBase, container: DecoderKeyedContainerContainer, nestedPath: [CodingKey]) {
        self.decoder = decoder
        self.container = container
        self.nestedPath = nestedPath
    }
}

struct DecoderDefaultUnkeyedContainer: DecoderUnkeyedContainer {
    
    var decoder: AnyDecoderBase
    var container: DecoderUnkeyedContainerContainer
    var nestedPath: [CodingKey]
    
    init(decoder: AnyDecoderBase, container: DecoderUnkeyedContainerContainer, nestedPath: [CodingKey]) {
        self.decoder = decoder
        self.container = container
        self.nestedPath = nestedPath
    }
    
    var currentIndex: Int = 0
}
