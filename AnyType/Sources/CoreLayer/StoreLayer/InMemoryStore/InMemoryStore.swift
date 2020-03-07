//
//  InMemoryStore.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: - Protocols
protocol InMemoryStoreStorageHolderProtocol {
    associatedtype Key: Hashable
    associatedtype Value
    subscript (_ key: Key) -> Value? { get set }
}

protocol InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol: InMemoryStoreStorageHolderProtocol where Self.Key == String, Self.Value == Any {
    func add<T>(_ entry: T)
    func get<T>(by type: T.Type) -> T?
}

private protocol InMemoryStoreStorageHolderProtocol_Private: InMemoryStoreStorageHolderProtocol {
    var store: InMemoryStoreFacade.Store<Key, Value> { get }
}

extension InMemoryStoreStorageHolderProtocol_Private {
    subscript (_ key: Key) -> Value? {
        get {
            self.store[key]
        }
        set {
            self.store[key] = newValue
        }
    }
}

private protocol InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol_Private: InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol, InMemoryStoreStorageHolderProtocol_Private {
}

extension InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol_Private {
    // TODO: Rethink.
    // We should use CORRECT reflection here.
    // This type will infere its name with typealias.
    // Consider following:
    // typealias Foo = Bar
    // let key = typeName(some: Foo.self) // key == "Foo"
    // let realKey = typeName(some: Bar.self) // key == "Bar"
    func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
    
    func add<T>(_ entry: T) {
        let key = typeName(some: T.self)
        self.store[key] = entry
    }
    
    func get<T>(by type: T.Type) -> T? {
        let key = typeName(some: T.self)
        return self.store[key] as? T
    }
}

// MARK: - Base Store
extension InMemoryStoreFacade {
    // override in subclasses?
    // do we need subclasses?
    // ???
    class Store<Key: Hashable, Value> {
        private lazy var store: Dictionary<Key, Value> = [:]
        subscript (_ key: Key) -> Value? {
            get {
                self.store[key]
            }
            set {
                if newValue == nil {
                    self.store.removeValue(forKey: key)
                }
                else {
                    self.store[key] = newValue
                }
            }
        }
    }
}

// MARK: - Facade
class InMemoryStoreFacade: InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol, InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol_Private {
    typealias Key = String
    typealias Value = Any

    static let shared: InMemoryStoreFacade = .init()
    fileprivate var store: Store<Key, Value> = .init()
    
    func setup() {
        // put all storages inside.
        self.add(Services())
        self.add(MiddlewareConfigurationStore())
        self.add(BlockLocalStore())
        self.add(PageToggleStore())
    }
    
    init() {
        self.setup()
    }
    
    var services: Services? { self.get(by: Services.self) }
    var middlewareConfigurationStore: MiddlewareConfigurationStore? { self.get(by: MiddlewareConfigurationStore.self) }
    var blockLocalStore: BlockLocalStore? { self.get(by: BlockLocalStore.self) }
    var pageToggleStore: PageToggleStore? { self.get(by: PageToggleStore.self) }
}

// MARK: - Custom Storages
extension InMemoryStoreFacade {
    
    // MARK: - Services
    class Services: InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol, InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol_Private {
        typealias Key = String
        typealias Value = Any
        
        fileprivate var store: Store<Key, Value> = .init()
    }
    
    // MARK: - Middleware Configuration
    class MiddlewareConfigurationStore: InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol, InMemoryStoreStorageHolderWithKeyStringAndValueAnyProtocol_Private {
        typealias Key = String
        typealias Value = Any
        
        fileprivate var store: Store<Key, Value> = .init()
    }
    
    // MARK: - Block Information
    // Now we keep .blockId -> .toggle
    // One-to-one .blockId -> Value
    
    // But we could keep .pageId -> [blockIds].map{block(blockId) IS toggle}
    class BlockLocalStore: InMemoryStoreStorageHolderProtocol, InMemoryStoreStorageHolderProtocol_Private {
        struct Key: Hashable {
            var blockId: MiddlewareBlockInformationModel.Id
        }
        
        struct Value {
            var toggled: Bool
        }
        
        fileprivate var store: Store<Key, Value> = .init()
    }
    
    class PageToggleStore: InMemoryStoreStorageHolderProtocol, InMemoryStoreStorageHolderProtocol_Private {
        struct Key: Hashable {
            var pageId: MiddlewareBlockInformationModel.Id
        }
        
        struct Value {
            var allTogglesIds: [MiddlewareBlockInformationModel.Id]
        }
        
        fileprivate var store: Store<Key, Value> = .init()
    }
}
