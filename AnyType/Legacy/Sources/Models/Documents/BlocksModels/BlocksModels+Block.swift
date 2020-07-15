//
//  BlocksModels+Block.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os

private extension Logging.Categories {
    static let blocksModelsBlock: Self = "BlocksModels.Block"
}

// MARK: - Block Kind
extension BlocksModels.Block {
    enum Kind {
        case meta, block
    }
}

// MARK: - BlockModel
extension BlocksModels.Block {
    final class BlockModel: ObservableObject {
        private var _information: BlocksModelsInformationModelProtocol
        private var _parent: BlockId?
        private var _kind: BlockKind {
            switch self._information.content {
            case .smartblock(_): return .meta
            default: return .block
            }
        }
        
        required init(information: BlocksModelsInformationModelProtocol) {
            self._information = information
        }
    }
}

extension BlocksModels.Block.BlockModel: BlocksModelsBlockModelProtocol {
    var information: BlocksModelsInformationModelProtocol {
        get { self._information }
        set { self._information = newValue }
    }
    
    var parent: BlockId? {
        get { self._parent }
        set { self._parent = newValue }
    }
    
    var kind: BlockKind { self._kind }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.objectWillChange.eraseToAnyPublisher() }
    func didChange() { self.objectWillChange.send() }
}

// MARK: UserSession / Focus
extension BlocksModels.Block {
    enum Focus {
        enum Position {
            case unknown
            case beginning
            case end
            case at(Int)
        }
    }
}

// MARK: UserSession
extension BlocksModels.Block {
    class UserSession: ObservableObject {
        struct Information {
            var isToggled: Bool
        }
        var _firstResponder: String?
        var _focusAt: Position?
        var _storage: [String: Information] = [:]
    }
}

extension BlocksModels.Block.UserSession: BlocksModelsUserSessionModelProtocol {
    func isToggled(by id: BlockId) -> Bool { self._storage[id]?.isToggled ?? false }
    func isFirstResponder(by id: BlockId) -> Bool { self._firstResponder == id }
    func firstResponder() -> BlockId? { self._firstResponder }
    func focusAt() -> Position? { self._focusAt }
    func setToggled(by id: BlockId, value: Bool) { self._storage[id] = (self._storage[id] ?? .init(isToggled: value)) }
    func setFirstResponder(by id: BlockId) { self._firstResponder = id }
    func setFocusAt(position: Position) { self._focusAt = position }
    
    func unsetFirstResponder() { self._firstResponder = nil }
    func unsetFocusAt() { self._focusAt = nil }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.objectWillChange.eraseToAnyPublisher() }
    func didChange() { self.objectWillChange.send() }
}

// MARK: - Container
extension BlocksModels.Block {
    final class Container {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Model = BlockModel
        
        private var _rootId: BlockId?
        private var _models: [BlockId: Model] = [:]
        private var _userSession: UserSession = .init()
        private var _detailsContainer: BlocksModels.Block.DetailsContainer = .init()
        
        func _choose(by id: BlockId) -> ChosenBlock? {
            if let value = self._models[id] {
                return .init(container: self, chosenBlock: value)
            }
            else {
                return nil
            }
        }
                        
        private func _get(by id: BlockId) -> Model? {
            self._models[id]
        }
        
        private func _add(_ block: Model) {
            if self._models[block.information.id] != nil {
                // tell thta
                let logger = Logging.createLogger(category: .blocksModelsBlock)
                os_log(.debug, log: logger, "We shouldn't replace block by add operation. Skipping...")
                return
            }
            self._models[block.information.id] = block
        }
    }
}

extension BlocksModels.Block.Container: BlocksModelsContainerModelProtocol {
    // MARK: RootId
    var rootId: BlockId? {
        get {
            self._rootId
        }
        set {
            self._rootId = newValue
        }
    }
    
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId> {
        .init(self._models.keys.makeIterator())
    }
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlocksModelsChosenBlockModelProtocol? {
        self._choose(by: id)
    }
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlocksModelsBlockModelProtocol? {
        self._models[id]
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
            self._models.removeValue(forKey: id)
            block.information.childrenIds.forEach(self.remove(_:))
        }
    }
    // MARK: - Operations / Add
    func add(_ block: BlocksModelsBlockModelProtocol) {
        let blockModel: Model = .init(information: block.information)
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
    
    // MARK: - Children / Replace
    /// If you would like to change children in parent, you should call this method.
    ///
    /// WARNING:
    /// This method doesn't change parent of previous model.
    /// You should add this functionality later.
    ///
    /// NOTES:
    /// This method also could change only children ids WITHOUT additional condition if block exists or not.
    /// For that, set parameter `shouldSkipGuardAgainstMissingIds` to `true`.
    ///
    /// - Parameters:
    ///   - childrenIds: Associated keys to children entries which parent we would like to change.
    ///   - parentId: An associated key to a parent entry in which we would like to change children.
    ///   - shouldSkipGuardAgainstMissingIds: A flag that notes if we should skip condition about existing entries.
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool = false) {
        
        guard let parent = self.choose(by: parentId) else {
            let logger = Logging.createLogger(category: .blocksModelsBlock)
            os_log(.debug, log: logger, "I can't find entry with id: %@", parentId)
            return
        }
                
        let existedIds = !shouldSkipGuardAgainstMissingIds ? childrenIds.filter { (childId) in
            if self.choose(by: childId) != nil {
                return true
            }
            else {
                let logger = Logging.createLogger(category: .blocksModelsBlock)
                os_log(.debug, log: logger, "I can't find entry with id: %@", parentId)
                return false
            }
        } : childrenIds
        
        var parentModel = parent.blockModel
        parentModel.information.childrenIds = existedIds
        /// TODO: Set children their new parentId if needed?
        /// Actually, yes, but not now.
        /// Do it later.
    }
    
    // MARK: - UserSession
    var userSession: UserSession {
        get {
            self._userSession
        }
    }
    
    // MARK: - DetailsContainer
    var detailsContainer: DetailsContainer {
        get {
            self._detailsContainer
        }
    }
}

extension BlocksModels.Block {
    final class ChosenBlock {
        typealias BlockId = BlocksModels.Aliases.BlockId
        private weak var _container: Container?
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

extension BlocksModels.Block.ChosenBlock: ObservableObject, BlocksModelsChosenBlockModelProtocol {
    var container: BlocksModelsContainerModelProtocol? {
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
        guard let parent = self._container?._choose(by: parentId) else { return Self.defaultIndentationLevel }
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
        guard let parent = self._container?._choose(by: parentId) else { return nil }
        return Self.init(parent)
    }
    
    func findRoot() -> Self? {
        sequence(first: self, next: {$0.findParent()}).reversed().first.flatMap(Self.init)
    }
    
    func childrenIds() -> [BlockId] {
        self.blockModel.information.childrenIds
    }
    
    func findChild(by id: BlockId) -> Self? {
        guard let child = self._container?._choose(by: id) else { return nil }
        return Self.init(child)
    }
    
    var isFirstResponder: Bool {
        get {
            self.container?.userSession.isFirstResponder(by: self._chosenBlock.information.id) ?? false
        }
        set {
            self.container?.userSession.setFirstResponder(by: self._chosenBlock.information.id)
        }
    }
    
    func unsetFirstResponder() {
        if self.isFirstResponder {
            self.container?.userSession.unsetFirstResponder()            
        }
    }
    
    var isToggled: Bool {
        get {
            self.container?.userSession.isToggled(by: self._chosenBlock.information.id) ?? false
        }
        set {
            self.container?.userSession.setToggled(by: self._chosenBlock.information.id, value: newValue)
        }
    }
    
    var focusAt: Position? {
        get {
            guard self.container?.userSession.firstResponder() == self._chosenBlock.information.id else { return nil }
            return self.container?.userSession.focusAt()
        }
        set {
            guard self.container?.userSession.firstResponder() == self._chosenBlock.information.id else { return }
            if let value = newValue {
                self.container?.userSession.setFocusAt(position: value)
            }
            else {
                self.container?.userSession.unsetFocusAt()
            }
        }
    }
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.blockModel.didChangePublisher() }
    func didChange() { self.blockModel.didChange() }
}

// MARK: DetailsContainer
extension BlocksModels.Block {
    final class DetailsContainer {
        typealias DetailsId = BlocksModels.Aliases.BlockId
        typealias Model = DetailsModel
        typealias ChosenModel = ChosenDetailsModel
        private var models: [DetailsId: Model] = [:]
        
        func _choose(by id: DetailsId) -> ChosenModel? {
            if let value = self.models[id] {
                return .init(container: self, nestedModel: value)
            }
            else {
                return nil
            }
        }
                        
        private func _get(by id: DetailsId) -> Model? {
            self.models[id]
        }
        
        private func _add(_ model: Model) {
            guard let parent = model.parent else {
                /// TODO: Add Logging
                /// We can't add details without parent. ( or block with details )
                let logger = Logging.createLogger(category: .blocksModelsBlock)
                os_log(.debug, log: logger, "We shouldn't add details with empty parent id. Skipping...")
                return
            }
            
            if self.models[parent] != nil {
                let logger = Logging.createLogger(category: .blocksModelsBlock)
                os_log(.debug, log: logger, "We shouldn't replace details by add operation. Skipping...")
                return
            }
            self.models[parent] = model
        }
        
        private func _remove(by id: DetailsId) {
            guard self.models.keys.contains(id) else {
                let logger = Logging.createLogger(category: .blocksModelsBlock)
                os_log(.debug, log: logger, "We shouldn't delete models if they are not in the collection. Skipping...")
                return
            }
            self.models.removeValue(forKey: id)
        }
    }
}

extension BlocksModels.Block.DetailsContainer: BlocksModelsDetailsContainerModelProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<DetailsId> { .init(self.models.keys.makeIterator()) }
    // MARK: - Operations / Choose
    func choose(by id: DetailsId) -> BlocksModelsChosenDetailsModelProtocol? { self._choose(by: id) }
    // MARK: - Operations / Get
    func get(by id: DetailsId) -> BlocksModelsDetailsModelProtocol? { self._get(by: id) }
    // MARK: - Operations / Remove
    func remove(_ id: DetailsId) { self._remove(by: id) }
}

extension BlocksModels.Block.DetailsContainer {
    class DetailsModel {
        typealias PageDetails = BlocksModels.Aliases.PageDetails
        /// Its a Details model.
        /// It has PageDetails (?)
        var _details: PageDetails = .empty
        required init(details: PageDetails) {
            self._details = details
        }
    }
    
    class ChosenDetailsModel {
        /// Represents chosen details over this container.
        /// Can switch to another details if needed. (?)
        typealias DetailsId = BlocksModels.Aliases.BlockId
        typealias Container = BlocksModels.Block.DetailsContainer
        typealias NestedModel = DetailsModel
        private weak var _container: Container?
        private var _nestedModel: NestedModel
        init(container: Container, nestedModel: NestedModel) {
            self._container = container
            self._nestedModel = nestedModel
        }
        required init(_ chosen: ChosenDetailsModel) {
            self._container = chosen._container
            self._nestedModel = chosen._nestedModel
        }
        class func create(_ chosen: ChosenDetailsModel) -> Self { .init(chosen) }

    }
}

extension BlocksModels.Block.DetailsContainer.DetailsModel: BlocksModelsDetailsModelProtocol {
    var details: PageDetails {
        get {
            self._details
        }
        set {
            self._details = newValue
        }
    }
    
    /// TODO: Add parent to model or extend PageDetails to store parentId.
    var parent: DetailsId? {
        get {
            nil
        }
        set {
            
        }
    }
}

extension BlocksModels.Block.DetailsContainer.ChosenDetailsModel: BlocksModelsChosenDetailsModelProtocol {
    var container: BlocksModelsDetailsContainerModelProtocol? {
        self._container
    }
    var detailsModel: BlocksModelsDetailsModelProtocol {
        self._nestedModel
    }
}
