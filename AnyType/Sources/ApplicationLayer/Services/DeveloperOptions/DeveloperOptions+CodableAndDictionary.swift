//
//  DeveloperOptions+CodableAndDictionary.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

protocol CodableAndDictionary: Codable {}
extension CodableAndDictionary {
    static func create(dictionary: [String : AnyObject]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try JSONDecoder().decode(Self.self, from: data)
        //self.init(from: JSONDecoder.self)
    }
    func dictionary() -> [String : AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        guard let result = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        
        return result as? [String : AnyObject]
    }
}

extension DeveloperOptions {
    class SettingsSerialization {
        struct Entry {
            enum Value {
                case bool(Bool)
                case int(Int)
                case string(String)
                init?(value: AnyObject) {
                    switch value {
                    case let v as Bool: self = .bool(v)
                    case let v as Int: self = .int(v)
                    case let v as String: self = .string(v)
                    default: return nil
                    }
                }
            }
            
            var title: String?
            var value: Value?
            var keypath: String
            
            var anyValue: AnyObject? {
                guard let theValue = value else {
                    return nil
                }
                switch theValue {
                case .bool(let value): return value as AnyObject
                case .int(let value): return value as AnyObject
                case .string(let value): return value as AnyObject
                }
            }
            init(keypath: String) {
                self.keypath = keypath
            }
        }
    }
}

extension DeveloperOptions {
    enum F<T> {
        case empty
        case x(T)
        case x_xs(T, ArraySlice<T>)
        init(_ array: ArraySlice<T>) {
            switch array.count {
            case 0: self = .empty
            case 1: self = .x(array[0])
            default: self = .x_xs(array[0], array.dropFirst())
            }
        }
    }
}

extension DeveloperOptions.SettingsSerialization {
    typealias Settings = DeveloperOptions.Settings
    typealias F = DeveloperOptions.F
    class func plaintify(dictionary: [String : AnyObject]) -> [Entry] {
        func plaintify(dictionary: [String : AnyObject], key: String) -> [Entry] {
            func createKeypath(lhs: String, rhs: String) -> String {
                return lhs.isEmpty ? rhs : lhs + "." + rhs
            }
            return dictionary.flatMap { (k, v) -> [Entry] in
                let keypath = createKeypath(lhs: key, rhs: k)
                if let theValue = v as? [String : AnyObject] {
                    return plaintify(dictionary: theValue, key: keypath)
                }
                else {
                    // create Cell.
                    // key is keypath.
                    guard let value = Entry.Value(value: v) else {
                        return []
                    }
                    
                    var entry = Entry(keypath: keypath)
                    entry.value = value
                    entry.title = k
                    return [entry]
                }
            }
        }
        return plaintify(dictionary: dictionary, key: "")
    }
    
    class func plaintify(settings: Settings) -> ([String : AnyObject], [Entry]) {
        guard let dictionary = settings.dictionary() else {
            return ([:], [])
        }
        
        let entries = self.plaintify(dictionary: dictionary)
        return (dictionary, entries)
    }
    
    class func fromKeyPath(keypath: String) -> [String] {
        return keypath.split(separator: ".").map {String($0)}
    }
    
    class func headTail<T>(array: [T]) -> (T, [T])? {
        return array.isEmpty ? nil : (array[0], Array(array.dropFirst()))
    }

    class func updated(dictionary: [String : AnyObject], keypath: [String], value: AnyObject) -> [String : AnyObject] {
        var dictionary = dictionary
        
        switch F(ArraySlice(keypath)) {
        case .empty: break
        case let .x(head): dictionary[head] = value
        case let .x_xs(head, tail):
            if let nestedDictionary = dictionary[head] as? [String : AnyObject] {
                let value = updated(dictionary: nestedDictionary, keypath: Array(tail), value: value)
                dictionary[head] = value as AnyObject
            }
        }
        
        return dictionary
    }
    
    class func immerse(entries: [Entry], into settings: Settings) -> Settings {
        let dictionary = settings.dictionary() ?? [:]
        
        let resultDictionary = entries.reduce(dictionary) { (result, entry) in
            let keypath = entry.keypath
            guard let value = entry.anyValue else {
                return result
            }
            
            let items = fromKeyPath(keypath: keypath)
            return self.updated(dictionary: result, keypath: items, value: value)
        }
        
        guard let result = try? Settings.create(dictionary: resultDictionary) else {
            return settings
        }
        
        return result
    }
}
