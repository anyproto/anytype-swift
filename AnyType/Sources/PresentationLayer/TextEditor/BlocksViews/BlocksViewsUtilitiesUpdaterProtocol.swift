//
//  BlocksViewsUtilitiesUpdaterProtocol.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

protocol BlocksViewsUtilitiesUpdaterProtocol {
    associatedtype Key
    associatedtype Model
    
    func update(at: Key, by block: Model)
    
    // NOTE:
    // Actually, beforeBlock is not a beforeBlock, it is insert(block:at:)
    // Consider indices [0, 1, 2, 3]
    // insert "before" 1 index mean insert "at" index.
    func insert(block: Model, at: Key)
    func insert(block: Model, afterBlock: Key)
    func delete(at: Key)
}

extension BlocksViews.Base.Utilities {
    final class AnyUpdater<Key, Model>: BlocksViewsUtilitiesUpdaterProtocol {
        private class __Base<Key, Model>: BlocksViewsUtilitiesUpdaterProtocol {
            func update(at: Key, by block: Model) {
                fatalError()
            }
            
            func insert(block: Model, at: Key) {
                fatalError()
            }
            
            func insert(block: Model, afterBlock: Key) {
                fatalError()
            }
            
            func delete(at: Key) {
                fatalError()
            }
            
            init() {
                guard type(of: self) != __Base.self else {
                    fatalError("Cannot initialise, must subclass")
                }
            }
        }
        
        private final class __Box<Wrapped: BlocksViewsUtilitiesUpdaterProtocol>: __Base<Wrapped.Key, Wrapped.Model> {
            var concrete: Wrapped
            init(_ concrete: Wrapped) {
                self.concrete = concrete
            }
            override func update(at: Wrapped.Key, by block: Wrapped.Model) {
                self.concrete.update(at: at, by: block)
            }
            override func insert(block: Wrapped.Model, at: Wrapped.Key) {
                self.concrete.insert(block: block, at: at)
            }
            override func insert(block: Wrapped.Model, afterBlock: Wrapped.Key) {
                self.concrete.insert(block: block, afterBlock: afterBlock)
            }
            override func delete(at: Wrapped.Key) {
                self.concrete.delete(at: at)
            }
        }

        private let box: __Base<Key, Model>
        
        init<Concrete: BlocksViewsUtilitiesUpdaterProtocol>(_ concrete: Concrete) where Concrete.Key == Key, Concrete.Model == Model {
            box = __Box(concrete)
        }
        
        func update(at: Key, by block: Model) {
            self.box.update(at: at, by: block)
        }
        
        func insert(block: Model, at: Key) {
            self.box.insert(block: block, at: at)
        }
        
        func insert(block: Model, afterBlock: Key) {
            self.box.insert(block: block, afterBlock: afterBlock)
        }
        
        func delete(at: Key) {
            self.box.delete(at: at)
        }
    }
}
