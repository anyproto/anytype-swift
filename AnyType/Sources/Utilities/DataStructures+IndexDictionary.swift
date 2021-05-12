//
//  DataStructures+IndexDictionary.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

/// Usage:
// You have an array of entries that are Identifiable.
// let array: [Identifiable]
// Next, you would like to access to array elements in appropriate time and don't care about memory overhaead.
// Suppose, that you have following manipulation:
// Insert 3 numbers contigously into array at position 10.
// Suppose, that array have 20 elements before insertion.
// -> array.count == 20
// -> array[10..<13] = [1,2,3]
// Ok, that means that we have to take elements from 13..<20 and retrieve their ID.
// -> for i in array[13..<20].map{$0.id}
// and after that we have to increase positions of these elements by 3.
// -> self.indexDictionary.increase(array[13..<20].map{$0.id}, count: 3)
// Suppose, that you have to delete several elements contigously in array.
// In this situation you have to decrease values (positions) in this indexDictionary that are corresponding to ids of elements, which positions are _after_ last position of deleted elements.
// But.
// If you want to add/remove arbitrary IndexSet of elements, you have to find ranges, in which positions of elements should be increased or decreased by amount between [0..count_of_deleted_or_added_elements]

extension DataStructures {
    class IndexDictionary<Key: Hashable> {
        typealias Value = Array<Any>.Index
        private var dictionary: [Key: Value] = [:]
    }
}

// MARK: Public API
extension DataStructures.IndexDictionary {
    func update(_ values: [Key]) {
        var dictionary = [Key: Value].init()
        for (index, value) in values.enumerated() {
            dictionary[value] = index
        }
        self.dictionary = dictionary
    }
    
    subscript (_ key: Key) -> Value? {
        get {
            self.dictionary[key]
        }
        set {
            if newValue.isNil {
                self.dictionary.removeValue(forKey: key)
            }
            else {
                self.dictionary[key] = newValue
            }
        }
    }
    
    func add(_ key: Key, _ value: Value?) {
        self[key] = value
        //            if let value = value {
        //                for i in value ..< self.count {
        //
        //                }
        //            }
    }
    
    func remove(_ key: Key) {
        self[key] = nil
    }
}

// MARK: Private API / Checkers
private extension DataStructures.IndexDictionary {
    var count: Int { self.dictionary.count }
    var isEmpty: Bool { self.dictionary.isEmpty }
}

// MARK: Private API / Increase|Decrease
private extension DataStructures.IndexDictionary {
    func increase(_ keys: [Key], count: Int) {
        for key in keys {
            self[key] = self[key].flatMap{$0.advanced(by: count)}
        }
    }
    
    func increase(_ key: Key) {
        self[key] = self[key].flatMap{$0.advanced(by: 1)}
    }
    
    func decrease(_ keys: [Key], count: Int) {
        for key in keys {
            self[key] = self[key].flatMap{$0.advanced(by: count)}.flatMap{$0 < 0 ? nil : $0}
        }
    }
    
    func decrease(_ key: Key) {
        self[key] = self[key].flatMap{$0.advanced(by: -1)}.flatMap{$0 < 0 ? nil : $0}
    }
}
