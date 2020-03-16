//
//  BlocksViews+Base+Utilities+Updater.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: Updater
extension BlocksViews.Base.Utilities {
    class TreeUpdater<Wrapped: BlocksViewsViewModelHolder> {
        typealias Model = Wrapped.ViewModel.BlockModel
        typealias Key = Wrapped.ViewModel.BlockModel.FullIndex
        var value: Wrapped
        var indexDictionary: DataStructures.IndexDictionary<Key> = .init()
        var updater: BlockModels.Updater<Model>
        
        func configured(_ value: Wrapped) -> Self {
            self.value = value
            self.updater = .init(value: value.ourViewModel.getBlock())
            return self
        }
        init(value: Wrapped) {
            self.value = value
            self.updater = .init(value: value.ourViewModel.getBlock())
        }
    }
}

// MARK: BlockViewUtilitiesUpdaterProtocol
extension BlocksViews.Base.Utilities.TreeUpdater: BlocksViewsUtilitiesUpdaterProtocol {
    // check that we could update?...
    // Or not?
    // Just update, hehe.
    func update(at: Key, by block: Model) {
        self.updater.update(at: at, by: block)
    }
    func delete(at: Key) {
        self.updater.delete(at: at)
    }
    func insert(block: Wrapped.ViewModel.BlockModel, afterBlock: Wrapped.ViewModel.BlockModel.FullIndex) {
        self.updater.insert(block: block, afterBlock: afterBlock)
    }
    func insert(block: Wrapped.ViewModel.BlockModel, at: Wrapped.ViewModel.BlockModel.FullIndex) {
        self.updater.insert(block: block, at: at)
    }
}
