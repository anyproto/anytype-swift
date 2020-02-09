//
//  DocumentViewModel+Updates.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 02.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// TODO: Add IndexDictionary optimizations to not to rebuild it on each builders array change.

// MARK: Test Actions.
// TODO: Rename them!
extension DocumentViewModel {
    func testUpdate(at: Block.ID, by block: Block) {
        guard let index = self.indexDictionary[at] else { return }
        update(at: index, by: block)
    }
    
    func testInsert(block: Block, beforeBlock: Block.ID) {
        guard let index = self.indexDictionary[beforeBlock] else { return }
        testInsert(block: block, before: index)
    }
    
    func testInsertAfter(_ block: Block, _ afterBlock: Block.ID) {
        testInsert(block: block, afterBlock: afterBlock)
    }
    
    func testInsert(block: Block, afterBlock: Block.ID) {
        guard let index = self.indexDictionary[afterBlock] else { return }
        testInsert(block: block, after: index)
    }
    
    func testDelete(block: Block.ID) {
        guard let index = self.indexDictionary[block] else { return }
        testDelete(at: index)
    }
    
    private func testDelete(at: Int) {
        delete(at: at)
    }
    
    private func testInsert(block: Block, before: Int) {
        guard builders.indices.contains(before) else { return }
        let at = before.advanced(by: -1)
        insert(block: block, at: at)
    }
    
    private func testInsert(block: Block, after: Int) {
        guard builders.indices.contains(after) else { return }
        let at = after.advanced(by: 1)
        insert(block: block, at: at)
    }

}
extension DocumentViewModel {
    
    private func update(at: Int, by block: Block) {
        guard builders.indices.contains(at) else { return }
        for viewModel in BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: [block]) {
            builders[at] = viewModel
        }
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
    }
    private func move(from: Int, to: Int) {
        guard builders.indices.contains(from), builders.indices.contains(to) else { return }
        // do something
    }
    private func insert(block: Block , at: Int) {
        // 0 to count
        // Yes, it could equal count if we want to insert at the end of builders.
        guard (builders.indices.startIndex ... builders.indices.endIndex).contains(at) else { return }
        
        // we should insert into underlying list of blocks and call redraw.
        var blocks = builders.compactMap{$0 as? BlocksViews.Base.BlockViewModel}.compactMap{$0.getBlock()}
        blocks.insert(block, at: at)
        let newBuilders = BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: blocks)
        self.update(builders: newBuilders)
        
        print("\(#function) builders count: \(builders.count)")
    }
}
