//
//  InMemoryStore.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

/// In memory store
class InMemoryStore {
    static let shared = InMemoryStore()
    
    private lazy var storedDatas: Dictionary<String, Any> = [:]
    
    private init() {}
    
    
    private func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
    
    func add<T>(service: T) {
        let key = typeName(some: T.self)
        storedDatas[key] = service
    }
    
    func get<T>(by type: T.Type) -> T? {
        let key = typeName(some: T.self)
        return storedDatas[key] as? T
    }
}
