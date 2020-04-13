//
//  BlocksViews+Base+Utilities+Legacy_SequenceUpdater.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
#warning("DeveloperMessages.FileIsDeprecated")

// MARK: Updater
extension BlocksViews.Base.Utilities {
    class Legacy_SequenceUpdater<Wrapped: Legacy_BlockViewBuildersProtocolHolder> {
        typealias Model = BlockViewBuilderProtocol.Model
        typealias Key = BlockViewBuilderProtocol.IndexID
        var value: Wrapped
        var indexDictionary: DataStructures.IndexDictionary<Key> = .init()
        var builders: [BlockViewBuilderProtocol] {
            get { value.builders }
            set {
//                self.syncDictionary(newValue.compactMap{$0.id})
                value.builders = newValue
            }
        }
        func configured(_ value: Wrapped) -> Self {
            self.value = value
            return self
        }
        init(value: Wrapped) {
            self.value = value
        }
    }
}

// MARK: Update builders.
extension BlocksViews.Base.Utilities.Legacy_SequenceUpdater {
    private func syncDictionary(_ values: [Key]) {
        self.indexDictionary.update(values)
    }
    func update(builders: [BlockViewBuilderProtocol]) {
        self.syncDictionary(builders.compactMap{$0.id})
        self.builders = builders
    }
}

// MARK: Updater / Updates
extension BlocksViews.Base.Utilities.Legacy_SequenceUpdater: BlocksViewsUtilitiesUpdaterProtocol {
    func update(at: Key, by block: Model) {
        guard let index = self.indexDictionary[at] else { return }
        update(at: index, by: block)
    }
    
    func insert(block: Model, at: Key) {
        guard let index = self.indexDictionary[at] else { return }
        testInsert(block: block, at: index)
    }
        
    func insert(block: Model, afterBlock: Key) {
        guard let index = self.indexDictionary[afterBlock] else { return }
        testInsert(block: block, after: index)
    }
    
    func delete(at: Key) {
        guard let index = self.indexDictionary[at] else { return }
        delete(at: index)
    }
}

extension BlocksViews.Base.Utilities.Legacy_SequenceUpdater {
        
    private func testInsert(block: Model, at: Int) {
        guard builders.indices.contains(at) else { return }
        insert(block: block, at: at)
    }
    
    private func testInsert(block: Model, after: Int) {
        guard builders.indices.contains(after) else { return }
        let at = after.advanced(by: 1)
        insert(block: block, at: at)
    }

}

extension BlocksViews.Base.Utilities.Legacy_SequenceUpdater {
    
    private func update(at: Int, by block: Model) {
        guard builders.indices.contains(at) else { return }
        for viewModel in BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: [block]) {
            builders[at] = viewModel
        }
        self.update(builders: builders)
    }
    private func delete(at: Int) {
        guard builders.indices.contains(at) else { return }
        
        // these elements we should update.
//        let suffix = builders.indices.suffix(from: at)
//        for key in suffix.map({ builders[$0].id }) {
//            // we should decrease indices.
////            self.indexDictionary[key] -= 1
//        }
        builders.remove(at: at)
        self.update(builders: builders)
    }
    private func move(from: Int, to: Int) {
        guard builders.indices.contains(from), builders.indices.contains(to) else { return }
        // do something
    }
    private func insert(block: Model , at: Int) {
        // 0 to count
        // Yes, it could equal count if we want to insert at the end of builders.
        guard (builders.indices.startIndex ... builders.indices.endIndex).contains(at) else { return }
        
        // we should insert into underlying list of blocks and call redraw.
        var blocks = builders.compactMap({$0 as? BlocksViews.Base.ViewModel}).map({$0.getBlock()})
        blocks.insert(block, at: at)
        let newBuilders = BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: blocks.map{$0})
        self.update(builders: newBuilders)
    }
}
