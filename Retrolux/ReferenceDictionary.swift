//
//  ReferenceDictionary.swift
//  Retrolux
//
//  Created by Brendan Henderson on fgght  12/23/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

extension Dictionary where Value: RangeReplaceableCollection, Value: ExpressibleByArrayLiteral {
    
    /// append the new element to value for key
    public mutating func appendElement(_ newElement: Value.Element, forKey key: Key) {
        var elements = self[key] ?? []
        elements.append(newElement)
        self[key] = elements
    }
}

public enum ReferenceOption {
    case weak
    case strong
}

/// a workaround until a fix is found to store a dictionary of weak objects
open class ReferenceDictionary<Key: AnyObject & Hashable, Value: AnyObject>: Sequence {
    
    open let keyOption: ReferenceOption
    open let valueOption: ReferenceOption
    
    /// storage is the raw storage of this dictionary.  It will likely hold empty shells. Use .forEach(_:) to filter out
    private var storage: [/*.hashValue*/ Int: [(key: ReferenceShell<Key>, value: ReferenceShell<Value>)]] = [:]
    
    // capture and set elements from self.storage
    open var elements: Dictionary<Key, Value> {
        get {
            var dictionary: Dictionary<Key, Value> = [:]
            
            self.forEach {
                dictionary[$0.key] = $0.value
            }
            
            return dictionary
        }
        set {
            
            self.storage.removeAll()
            
            self.storage = newValue.reduce(into: self.storage, { $0.appendElement((key: ReferenceShell($1.key, self.keyOption), value: ReferenceShell($1.value, self.valueOption)), forKey: $1.key.hashValue) })
        }
    }
    
    public init(_ elements: [Key: Value] = [:], key: ReferenceOption, value: ReferenceOption) {
        self.keyOption = key
        self.valueOption = value
        self.elements = elements
    }
    
    open var count: Int {
        var count: Int = 0
        self.forEach { _ in
            count += 1
        }
        return count
    }
    
    open func forEach(_ body: ((key: Key, value: Value)) throws -> Void) rethrows {
        
        for hashValue in self.storage.keys {
            try self.forEach(withHashValue: hashValue, body)
        }
    }
    
    open func forEach(withHashValue hashValue: Int, _ body: ((key: Key, value: Value)) throws -> Void) rethrows {
        
        var elements = self.storage[hashValue] ?? []
        
        var filterIndexes: [Int] = []
        defer {
            for index in filterIndexes {
                elements.remove(at: index)
            }
            self.storage[hashValue] = (elements.isEmpty ? nil : elements)
        }
        
        for (index, element) in elements.enumerated() {
            
            guard
                let key = element.key.value,
                let value = element.value.value
            else {
                filterIndexes.append(index)
                continue
            }
            
            try body((key, value))
        }
    }
    
    open subscript(key: Key) -> Value? {
        get {
            return self.object(forKey: key)
        }
        
        set {
            self.setObject(newValue, forKey: key)
        }
    }
    
    /// just an error to throw to break execution of getting value for key
    private struct _Break: Error {}
    
    open func object(forKey key: Key) -> Value? {
        
        var value: Value? = nil
        
        try? self.forEach(withHashValue: key.hashValue, {
            if $0.key == key {
                value = $0.value
                // shouldn't call == on keys more than needed.
                throw _Break()
            }
        })
        
        return value
    }
    
    open func setObject(_ newValue: Value?, forKey key: Key) {
        
        let hashValue = key.hashValue
        
        var elements = self.storage[hashValue] ?? []
        
        if !elements.isEmpty {
            // filter empty shells
            var removeIndexes: [Int] = []
            
            for (index, element) in elements.enumerated() {
                if element.key.value == nil {
                    removeIndexes.append(index)
                }
            }
            
            for index in removeIndexes.reversed() {
                elements.remove(at: index)
            }
            
            // remove previous value, if present
            if let index = elements.index(where: { $0.key.value == key }) {
                elements.remove(at: index)
            }
        }
        
        // set newValue, if present
        if newValue != nil {
            elements.append((ReferenceShell(key, self.keyOption), ReferenceShell(newValue!, self.valueOption)))
        }
        
        self.storage[hashValue] = elements.isEmpty ? nil : elements
    }
    
    public func makeIterator() -> Dictionary<Key, Value>.Iterator {
        
        return self.elements.makeIterator()
    }
}

// ReferenceShell holds a value weak or strong.
public struct ReferenceShell<T: AnyObject> {
    public let option: ReferenceOption
    
    private weak var weak: T?
    private var strong: T?
    
    public var value: T? {
        get {
            return self.weak ?? self.strong
        }
        set {
            switch self.option {
            case .weak:
                self.weak = newValue
                self.strong = nil
            case .strong:
                self.weak = nil
                self.strong = newValue
            }
        }
    }
    
    public init(_ value: T, _ option: ReferenceOption) {
        self.option = option
        switch option {
        case .weak: self.weak = value
        case .strong: self.strong = value
        }
    }
}
