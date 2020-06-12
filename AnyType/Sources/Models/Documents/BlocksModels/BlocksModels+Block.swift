//
//  BlocksModels+Block.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsBlock: Self = "BlocksModels.Block"
}

// MARK: - BlockModel
protocol BlocksModelsHasInformationProtocol {
    var information: BlocksModelsInformationModelProtocol { get set }
    init(information: BlocksModelsInformationModelProtocol)
}

protocol BlocksModelsHasParentProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    var parent: BlockId? {get set}
}

protocol BlocksModelsHasKindProtocol {
    typealias BlockKind = BlocksModels.Aliases.BlockKind
    var kind: BlockKind {get}
}

protocol BlocksModelsBlockModelProtocol: BlocksModelsHasInformationProtocol, BlocksModelsHasParentProtocol, BlocksModelsHasKindProtocol {}

extension BlocksModels.Block {
    final class BlockModel: BlocksModelsBlockModelProtocol {
        var information: BlocksModelsInformationModelProtocol
        var parent: BlockId?
        var kind: BlockKind {
            switch information.content {
            case .smartblock(_): return .meta
            default: return .block
            }
        }
        
        required init(information: BlocksModelsInformationModelProtocol) {
            self.information = information
        }
    }
}

// MARK: - Block Kind
extension BlocksModels.Block {
    enum Kind {
        case meta, block
    }
}

// MARK: - BlockModel Container (?)
extension BlocksModels.Block {
    final class Container {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Block = BlockModel
        internal var rootId: BlockId?
        private var blocks: [BlockId: Block] = [:]
        private var _userSession: UserSession = .init()
        
        func _choose(by id: BlockId) -> ChosenBlock? {
            if let value = self.blocks[id] {
                return .init(container: self, chosenBlock: value)
            }
            else {
                return nil
            }
        }
                        
        private func _get(by id: BlockId) -> Block? {
            self.blocks[id]
        }
        
        private func _add(_ block: Block) {
            if self.blocks[block.information.id] != nil {
                // tell thta
                let logger = Logging.createLogger(category: .blocksModelsBlock)
                os_log(.debug, log: logger, "We shouldn't replace block by add operation. Skipping...")
                return
            }
            self.blocks[block.information.id] = block
        }
    }
}

extension BlocksModels.Block.Container: BlocksModelsContainerModelProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId> {
        .init(self.blocks.keys.makeIterator())
    }
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlocksModelsChosenBlockModelProtocol? {
        self._choose(by: id)
    }
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlocksModelsBlockModelProtocol? {
        self.blocks[id]
    }
    // MARK: - Operations / Remove
    func remove(_ id: BlockId) {
        // go to parent and remove this block from a parent.
        if let parentId = self.get(by: id)?.parent, let parent = self._get(by: parentId) {
            var information = parent.information
            information.childrenIds = information.childrenIds.filter({$0 != id})
            parent.information = information
            //                self.blocks[parentId] = parent
        }
        
        if let block = self.get(by: id) {
            self.blocks.removeValue(forKey: id)
            block.information.childrenIds.forEach(self.remove(_:))
        }
    }
    // MARK: - Operations / Add
    func add(_ block: BlocksModelsBlockModelProtocol) {
        let blockModel: Block = .init(information: block.information)
        blockModel.parent = block.parent
        self._add(blockModel)
    }
    // MARK: - Children / Append
    func append(childId: BlockId, parentId: BlockId) {
        guard let child = self.choose(by: childId) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find entry with id: %@", parentId)
            return
        }
        guard let parent = self.choose(by: parentId) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find entry with id: %@", parentId)
            return
        }
        
        var childModel = child.blockModel
        childModel.information.id = parentId
        
        var parentModel = parent.blockModel
        var childrenIds = parentModel.information.childrenIds
        childrenIds.append(childId)
        parentModel.information.childrenIds = childrenIds
    }
    // MARK: - Children / Add Before
    private func insert(childId: BlockId, parentId: BlockId, at index: Int) {
        guard let parentModel = self.choose(by: parentId) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find parent with id: %@", parentId)
            return
        }
        
        guard var childModel = self.get(by: childId) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find child with id: %@", childId)
            return
        }
        
        var parent = parentModel.blockModel
        var childrenIds = parent.information.childrenIds
        childrenIds.insert(childId, at: index)
        parent.information.childrenIds = childrenIds
        
        /// And now set parent
        childModel.parent = parentId
    }
    func add(child: BlockId, beforeChild: BlockId) {
        /// First, we must find parent of beforeChild
        guard let parent = self.choose(by: beforeChild)?.findParent(), let index = parent.childrenIds().firstIndex(of: beforeChild) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find either parent or block itself with id: %@", beforeChild)
            return
        }
        
        let parentId = parent.blockModel.information.id
        
        self.insert(childId: child, parentId: parentId, at: index)
    }
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId) {
        /// First, we must find parent of afterChild
        guard let parent = self.choose(by: afterChild)?.findParent(), let index = parent.childrenIds().firstIndex(of: afterChild) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find either parent or block itself with id: %@", afterChild)
            return
        }
        
        let parentId = parent.blockModel.information.id
        
        let newIndex = index.advanced(by: 1)
        self.insert(childId: child, parentId: parentId, at: newIndex)
    }
    
    // MARK: - UserSession
    var userSession: UserSession {
        get {
            self._userSession
        }
    }
}

extension BlocksModels.Block {
    final class ChosenBlock {
        typealias BlockId = BlocksModels.Aliases.BlockId
        private var _container: Container
        private var _chosenBlock: BlockModel
        init(container: Container, chosenBlock: BlockModel) {
            self._container = container
            self._chosenBlock = chosenBlock
        }
        required init(_ chosen: ChosenBlock) {
            self._container = chosen._container
            self._chosenBlock = chosen._chosenBlock
        }
        class func create(_ chosen: ChosenBlock) -> Self {
            .init(chosen)
        }
    }
}

extension BlocksModels.Block.ChosenBlock: BlocksModelsChosenBlockModelProtocol {
    var container: BlocksModelsContainerModelProtocol {
        self._container
    }
    
    var blockModel: BlocksModelsBlockModelProtocol {
        self._chosenBlock
    }
    
    static var defaultIndentationLevel: Int { 0 }
    var indentationLevel: Int {
        if self.isRoot {
            return Self.defaultIndentationLevel
        }

        guard let parentId = self._chosenBlock.parent else { return Self.defaultIndentationLevel }
        guard let parent = self._container._choose(by: parentId) else { return Self.defaultIndentationLevel }
        switch self._chosenBlock.kind {
        case .meta: return parent.indentationLevel
        case .block: return parent.indentationLevel + 1
        }
    }
    
    var isRoot: Bool {
        self._chosenBlock.parent == nil
    }
    
    func findParent() -> Self? {
        if self.isRoot {
            return nil
        }

        guard let parentId = self._chosenBlock.parent else { return nil }
        guard let parent = self._container._choose(by: parentId) else { return nil }
        return Self.init(parent)
    }
    
    func findRoot() -> Self? {
        sequence(first: self, next: {$0.findParent()}).reversed().first.flatMap(Self.init)
    }
    
    func childrenIds() -> [BlockId] {
        self.blockModel.information.childrenIds
    }
    
    func findChild(by id: BlockId) -> Self? {
        guard let child = self._container._choose(by: id) else { return nil }
        return Self.init(child)
    }
    
    var isFirstResponder: Bool {
        get {
            self.container.userSession.isFirstResponder(by: self._chosenBlock.information.id)
        }
        set {
            self.container.userSession.setFirstResponder(by: self._chosenBlock.information.id)
        }
    }
    
    var isToggled: Bool {
        get {
            self.container.userSession.isToggled(by: self._chosenBlock.information.id)
        }
        set {
            self.container.userSession.setToggled(by: self._chosenBlock.information.id, value: newValue)
        }
    }
}

extension BlocksModels.Block {
    class UserSession {
        var storage: [String: String] = [:]
    }
}

extension BlocksModels.Block.UserSession: BlocksModelsUserSessionModelProtocol {
    func isToggled(by id: BlockId) -> Bool { false }
    func isFirstResponder(by id: BlockId) -> Bool { false }
    func firstResponder() -> BlockId? { nil }
    func setToggled(by id: BlockId, value: Bool) {}
    func setFirstResponder(by id: BlockId) {}
}

// MARK: - UserSession
protocol BlocksModelsUserSessionModelProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    func isToggled(by id: BlockId) -> Bool
    func isFirstResponder(by id: BlockId) -> Bool
    func firstResponder() -> BlockId?
    func setToggled(by id: BlockId, value: Bool)
    func setFirstResponder(by id: BlockId)
}

// MARK: - Container
protocol BlocksModelsHasUserSessionProtocol {
    typealias UserSession = BlocksModelsUserSessionModelProtocol
    var userSession: UserSession {get}
}

protocol BlocksModelsHasRootIdProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    var rootId: BlockId? {get set}
}

protocol BlocksModelsContainerModelProtocol: BlocksModelsHasRootIdProtocol, BlocksModelsHasUserSessionProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId>
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlocksModelsChosenBlockModelProtocol?
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlocksModelsBlockModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: BlockId)
    // MARK: - Operations / Add
    func add(_ block: BlocksModelsBlockModelProtocol)
    // MARK: - Children / Append
    func append(childId: BlockId, parentId: BlockId)
    // MARK: - Children / Add Before
    func add(child: BlockId, beforeChild: BlockId)
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId)
}

// MARK: - ChosenBlock
protocol BlocksModelsChosenBlockModelProtocol: BlocksModelsHasContainerProtocol, BlocksModelsHasBlockModelProtocol, BlocksModelsHasIndentationLevelProtocol, BlocksModelsCanBeRootProtocol, BlocksModelsFindParentAndRootProtocol, BlocksModelsFindChildProtocol, BlocksModelsCanBeFirstResponserProtocol, BlocksModelsCanBeToggledProtocol {}

// MARK: - ChosenBlock / BlockModel
protocol BlocksModelsHasContainerProtocol {
    var container: BlocksModelsContainerModelProtocol {get}
}

// MARK: - ChosenBlock / BlockModel
protocol BlocksModelsHasBlockModelProtocol {
    var blockModel: BlocksModelsBlockModelProtocol {get}
}

// MARK: - ChosenBlock / IndentationLevel
protocol BlocksModelsHasIndentationLevelProtocol {
    static var defaultIndentationLevel: Int {get}
    var indentationLevel: Int {get}
}

// MARK: - ChosenBlock / isRoot
protocol BlocksModelsCanBeRootProtocol {
    var isRoot: Bool {get}
}

// MARK: - ChosenBlock / FindRoot and FindParent
protocol BlocksModelsFindParentAndRootProtocol {
    func findParent() -> Self?
    func findRoot() -> Self?
}

// MARK: - ChosenBlock / Children
protocol BlocksModelsFindChildProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    func childrenIds() -> [BlockId]
    func findChild(by id: BlockId) -> Self?
}

// MARK: - ChosenBlock / isFirstRepsonder
protocol BlocksModelsCanBeFirstResponserProtocol {
    var isFirstResponder: Bool {get set}
}

// MARK: - ChosenBlock / isFirstRepsonder
protocol BlocksModelsCanBeToggledProtocol {
    var isToggled: Bool {get set}
}

