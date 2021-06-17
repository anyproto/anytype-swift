//
//  BlockModel+Updater.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlockModels {
    class Updater<Wrapped: BlockModels.Block.RealBlock> {
        typealias Model = Wrapped
        typealias InformationModel = MiddlewareBlockInformationModel
        typealias Key = Wrapped.FullIndex
        typealias KeyElement = Key.Element
        
        typealias Id = MiddlewareBlockInformationModel.Id
        typealias Children = Array<Wrapped>
        
        private var finder: Finder<Wrapped>
        private var relaxing: Relaxing = .init()
        private var value: Wrapped
        private var indexDictionary: DataStructures.IndexDictionary<Key> = .init()
        
        // MARK: Make ContinousIndexDictionary as Subclass of IndexDictionary.
        private var hashDictionary: Dictionary<Id, Key> = .init()
        
        func configured(_ value: Wrapped) -> Self {
            self.value = value
            self.finder = .init(value: value)
            self.relaxing.update(finder: self.finder)
            return self
        }
        
        init(value: Wrapped) {
            self.value = value
            self.finder = .init(value: value)
            self.relaxing.update(finder: self.finder)
        }
    }
}

// MARK: Update.
extension BlockModels.Updater {
//    private func syncDictionary(_ values: [FullIndex]) {
//        self.indexDictionary.update(values)
//    }
    func update(builders: [Wrapped]) {
//        self.syncDictionary(builders.compactMap{$0.id})
//        self.builders = builders
    }
}

// MARK: Updater / Updates
extension BlockModels.Updater {
    // In case of updates/deletes/inserts, we should rebuild indices ( done ) and also we should rebuild metablocks if needed.
    func update(at: Key, by block: Model) {
        if let value = self.finder.find(at) {
            value.information = block.information
            if let parent = self.finder.findParent(at) {
                self.relaxing.easyRelax(parent: parent)
            }
        }
    }
    
    func delete(at: Key) {
        if let parent = self.finder.findParent(at), let indexPath = at.last, let internalIndex = parent.getInternalIndex(for: indexPath) {
            guard parent.blocks.indices.contains(internalIndex) else { return }
            // we should update indices of these elements.
            var blocks = parent.blocks
            blocks.remove(at: internalIndex)
            parent.update(blocks)
            self.relaxing.easyRelax(parent: parent)
        }
    }
    
//    private func move(from: Int, to: Int) {
//        guard builders.indices.contains(from), builders.indices.contains(to) else { return }
//        // do something
//    }
    
    func insert(block: Model, at: Key) {
        self.insert(block: block, at: at, after: false)
    }
    
    func insert(block: Model, afterBlock: Key) {
        self.insert(block: block, at: afterBlock, after: true)
    }
    
    // Doesn't work well for nested metablocks.
    // Fuck.
    private func insert(block: Model, at: Key, after: Bool = false) {
        if let parent = self.finder.findParent(at), let indexPath = at.last, let internalIndex = parent.getInternalIndex(for: indexPath) {
            // 0 to count
            // Yes, it could equal count if we want to insert at the end of builders.
            let targetIndex = internalIndex.advanced(by: after ? 1 : 0)
            guard (parent.blocks.startIndex ... parent.blocks.endIndex).contains(targetIndex) else { return }
            // we should update indices of these elements.
            var blocks = parent.blocks
            blocks.insert(block, at: targetIndex)
            parent.update(blocks)
            self.relaxing.easyRelax(parent: parent)
        }
    }
}
