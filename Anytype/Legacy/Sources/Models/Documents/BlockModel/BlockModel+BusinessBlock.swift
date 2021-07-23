//
//  BlockModel+BusinessBlock.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

protocol MiddlewareBlockInformationModel {
    typealias Id = String
    var id: Id {get set}
    var childrenIds: [Id] {get set}
    var content: BlockType {get set}
    var fields: [String: Any] {get set}
    var restrictions: [String] {get set}
    var backgroundColor: String {get set}
    static func defaultValue() -> Self
    init(id: Id, content: BlockType)
    init(information: MiddlewareBlockInformationModel)
}

extension MiddlewareBlockInformationModel {
    mutating func update(id: Id) -> Self {
        self.id = id
        return self
    }
    mutating func update(childrenIds: [Id]) -> Self {
        self.childrenIds = childrenIds
        return self
    }
    mutating func update(content: BlockType) -> Self {
        self.content = content
        return self
    }
    mutating func update(fields: [String: Any]) -> Self {
        self.fields = fields
        return self
    }
    mutating func update(restrictions: [String]) -> Self {
        self.restrictions = restrictions
        return self
    }
    mutating func update(backgroundColor: String) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
}

protocol BusinessBlock {
    typealias Index = IndexPath
    var indexPath: Index {get set}
    var parent: BusinessBlock? {get set}
    var blocks: [BusinessBlock] {get set}
    @inline(__always) func childIndex() -> Index.Index
    @inline(__always) func createIndex(for blockAt: Index.Element) -> Index
    
    // Support inserts
    @inline(__always) func beforeIndex() -> Index.Index
    @inline(__always) func afterIndex() -> Index.Index
}

// MARK: Checks
extension BusinessBlock {
    var isRoot: Bool { self.parent == nil }
    var kind: BlockModels.Utilities.Inspector.BlockKind? { .inspect(self) }
}

// MARK: Indicies builders
extension BusinessBlock {
    static func newIndex(level: Index.Index, position: Index.Element) -> Index {
        .init(item: position, section: level)
    }
}

// MARK: Child blocks updates.
extension BusinessBlock {
    func update(blocks: [BusinessBlock]) -> [BusinessBlock] {
        blocks.enumerated().map{ (index, block) in
            var block = block
            block.indexPath = self.createIndex(for: index)
            block.parent = self
            return block
        }
    }
    mutating func update(_ blocks: [BusinessBlock]) {
        self.blocks = self.update(blocks: blocks)
    }
    mutating func buildIndexPaths() {
        self.blocks = self.update(blocks: blocks)
    }
}
