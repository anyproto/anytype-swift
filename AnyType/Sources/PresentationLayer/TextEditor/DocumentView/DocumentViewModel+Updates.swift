//
//  DocumentViewModel+Updates.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 02.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// TODO: Add IndexDictionary optimizations to not to rebuild it on each builders array change.
extension DocumentViewModel {
    func testUpdate(at: Block.ID, by block: Block) {
        guard let index = self.indexDictionary[at] else { return }
        update(at: index, by: block)
    }
    func testInsert(block: Block, before: Int) {
        guard builders.indices.contains(before), builders.indices.contains(before.advanced(by: -1)) else { return }
        let at = before.advanced(by: -1)
        insert(block: block, at: at)
    }
    func testInsert(block: Block, after: Int) {
        guard builders.indices.contains(after), builders.indices.contains(after.advanced(by: 1)) else { return }
        let at = after.advanced(by: 1)
        insert(block: block, at: at)
    }
    func testDelete(at: Int) {
        delete(at: at)
    }
    private func update(at: Int, by block: Block) {
        guard builders.indices.contains(at) else { return }
        for viewModel in BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: [block]) {
            builders[at] = viewModel
        }
    }
    private func delete(at: Int) {
        guard builders.indices.contains(at) else { return }
        
        // these elements we should update.
        let suffix = builders.indices.suffix(from: at)
        for key in suffix.map({ builders[$0].id }) {
            // we should decrease indices.
//            self.indexDictionary[key] -= 1
        }
        builders.remove(at: at)
        print("count: \(builders.count)")
    }
    private func move(from: Int, to: Int) {
        guard builders.indices.contains(from), builders.indices.contains(to) else { return }
        // do something
    }
    private func insert(block: Block , at: Int) {
        guard builders.indices.contains(at) else { return }
        for block in BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: [block]) {
            builders.insert(block, at: at)
        }
    }
}
