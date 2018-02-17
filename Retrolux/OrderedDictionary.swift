//
//  OrderedDictionary.swift
//  Retrolux
//
//  Created by Brendan Henderson on 2/15/18.
//  Copyright © 2018 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

/// a wrapper type to assure [(key: Key, value: Value)] has only one element per key
public struct OrderedDictionary<Key: Hashable, Value>: Sequence, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    
    public typealias Element = Dictionary<Key, Value>.Element
    
    public private(set) var elements: [Element]
    
    public init() {
        self.elements = []
    }
    
    public init(_ elements: [Element]) {
        self = elements.reduce(into: OrderedDictionary(), { $0[$1.key] = $1.value })
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init(sequence.map { $0 } as [Element])
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return self.value(forKey: key)
        }
        set {
            self.setValue(newValue, forKey: key)
        }
    }
    
    public func value(forKey key: Key) -> Value? {
        return self.elements.first(where: { [hash = key.hashValue] in $0.key.hashValue == hash && $0.key == key })?.value
    }
    
    /// if there is already a value for key, removes value and replaces at index if value.  Else, append if value
    public mutating func setValue(_ value: Value?, forKey key: Key) {
        if let index = self.elements.index(where: { [hash = key.hashValue] in $0.key.hashValue == hash && $0.key == key }) {
            self.elements.remove(at: index)
            value.map { self.elements.insert((key, $0), at: index) }
        } else {
            value.map { self.elements.append((key, $0)) }
        }
    }
    
    public func makeIterator() -> Array<Element>.Iterator {
        return self.elements.makeIterator()
    }
}
