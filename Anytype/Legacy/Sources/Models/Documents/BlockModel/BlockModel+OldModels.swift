//
//  BlockModel+OldModels.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

/// MetaBlock model.
/// Contains list of business blocks.
/// Suppose that we have MetaBlock model.
/// It is stored at the head of the list, but we don't keep it in actually.
/// let metaBlock = ...
/// metaBlock.indexPath // [1, 4]
/// metaBlock.blocks[0].indexPath // [1, 5]
/// metaBlock.blocks.last?.indexPath // [1, 4 + 1 + metaBlock.blocks.count - 1]
/// Proof:
/// when metaBlock.blocks.count == 0, then metaBlock.blocks.last?.indexPath // [1, 4 + 1 + 0 - 1] // [1, 4] ( if needed? ).
/// But in this case ( count == 0 ), we can't really access .blocks property, it is empty :D
/// when metaBlock.blocks.count == 1, then metaBlock.blocks.last?.indexPath // [1, 4 + 1 + 1 - 1] // [1, 5] ( right after MetaBlock )
struct MetaBlock: BusinessBlock {
    
    // could not be empty.
    // equal to index of first block?
    var indexPath: Self.Index
    var parent: BusinessBlock?
    var blocks: [BusinessBlock] = []
    @inline(__always) func childIndex() -> Self.Index.Index {
        self.indexPath.section
    }
    init(indexPath: IndexPath, blocks: [BusinessBlock]) {
        self.indexPath = indexPath
        self.blocks = self.update(blocks: blocks)
    }
    @inline(__always) func createIndex(for blockAt: Index.Element) -> Index {
        .init(item: self.indexPath.item + blockAt + 1, section: self.childIndex())
    }
    @inline(__always) func beforeIndex() -> Self.Index.Index {
        self.indexPath.item
    }
    
    @inline(__always) func afterIndex() -> Self.Index.Index {
        self.indexPath.item + self.blocks.reduce(0, {$0 + $1.afterIndex() - $1.beforeIndex()}) + 1
    }
}

/// Block model
/// Single block from middleware.
struct Block: Identifiable, BusinessBlock, MiddlewareBlockInformationModel {
    // MARK: MiddlewareBlockInformationModel
    static func defaultValue() -> Block { .default }
    
    var id: String
    var childrenIds: [String] = []
    var content: BlockType
    var fields: [String: Any] = .init()
    var restrictions: [String] = []
    
    var backgroundColor: String = ""
    
    init(id: String, content: BlockType) {
        self.id = id
        self.content = content
    }
    
    init(information: MiddlewareBlockInformationModel) {
        self.id = information.id
        self.childrenIds = information.childrenIds
        self.content = information.content
        self.fields = information.fields
        self.restrictions = information.restrictions
    }
    
    static let `defaultId`: String = "DefaultIdentifier"
    static let `defaultBlockType`: BlockType = .text(.createDefault(text: "DefaultText"))
    static let `default`: Block = .init(id: Self.defaultId, content: Self.defaultBlockType)

    
    // MARK: BusinessBlock
    var indexPath: Self.Index = BlockModels.Utilities.IndexGenerator.generateID() //.init()
    var parent: BusinessBlock?
    var blocks: [BusinessBlock] = []
    @inline(__always) func childIndex() -> Self.Index.Index {
        self.indexPath.index(after: self.indexPath.section)
    }
    @inline(__always) func createIndex(for blockAt: Index.Element) -> Index {
        .init(item: blockAt, section: self.childIndex())
    }
    
    @inline(__always) func beforeIndex() -> Self.Index.Index {
        self.indexPath.item
    }
    
    @inline(__always) func afterIndex() -> Self.Index.Index {
        self.indexPath.item + 1
    }
}

// MARK: Mocking
extension Block {
    static func mock(_ contentType: BlockType) -> Self {
        .init(id: UUID().uuidString, content: contentType)
    }
    static func mockText(_ type: BlockType.Text.ContentType) -> Self {
        .mock(.text(.init(attributedText: .init(string: ""), contentType: type)))
    }
    static func mockFile(_ type: BlockType.File.ContentType) -> Self {
        .mock(.file(.init(name: "", hash: "", state: .empty, contentType: type)))
    }
}
