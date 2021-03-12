//
//  Block+Implementation.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine
import os

fileprivate typealias Namespace = Block

private extension Logging.Categories {
    static let blocksModelsBlock: Self = "BlocksModels.Block"
}

// MARK: - BlockModel
extension Namespace {
    final class BlockModel: ObservableObject {
        @Published private var _information: BlockInformationModelProtocol
        private var _parent: BlockId?
        private var _kind: BlockKind {
            switch self._information.content {
            case .smartblock, .divider: return .meta
            case let .layout(layout) where layout.style == .div: return .meta
            case let .layout(layout) where layout.style == .header: return .meta
            default: return .block
            }
        }
        private var _didChangeSubject: PassthroughSubject<Void, Never> = .init()
        private var _didChangePublisher: AnyPublisher<Void, Never>
        required init(information: BlockInformationModelProtocol) {
            self._information = information
            self._didChangePublisher = self._didChangeSubject.eraseToAnyPublisher()
        }
    }
}

extension Namespace.BlockModel: BlockModelProtocol {
    var information: BlockInformationModelProtocol {
        get { self._information }
        set { self._information = newValue }
    }
    
    var parent: BlockId? {
        get { self._parent }
        set { self._parent = newValue }
    }
    
    var kind: BlockKind { self._kind }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self._didChangePublisher }
    func didChange() { self._didChangeSubject.send() }
    
    func didChangeInformationPublisher() -> AnyPublisher<BlockInformationModelProtocol, Never> {
        self.$_information.eraseToAnyPublisher()
    }
}

// MARK: UserSession
extension Namespace {
    class UserSession: ObservableObject {
        private var _firstResponder: String?
        private var _focusAt: Position?
        private var toggleStorage: [String: Bool] = [:]
    }
}

extension Namespace.UserSession: BlockUserSessionModelProtocol {
    func isToggled(by id: BlockId) -> Bool { self.toggleStorage[id, default: false] }
    func isFirstResponder(by id: BlockId) -> Bool { self._firstResponder == id }
    func firstResponder() -> BlockId? { self._firstResponder }
    func focusAt() -> Position? { self._focusAt }
    func setToggled(by id: BlockId, value: Bool) { self.toggleStorage[id] = value }
    func setFirstResponder(by id: BlockId) { self._firstResponder = id }
    func setFocusAt(position: Position) { self._focusAt = position }
    
    func unsetFirstResponder() { self._firstResponder = nil }
    func unsetFocusAt() { self._focusAt = nil }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self.objectWillChange.eraseToAnyPublisher() }
    func didChange() { self.objectWillChange.send() }
}

// MARK: - Container
extension Namespace {
    final class Container {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias Model = BlockModel
        
        private var _rootId: BlockId?
        private var _models: [BlockId: Model] = [:]
        private var _userSession: UserSession = .init()
        
        func _choose(by id: BlockId) -> ActiveRecord? {
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

extension Namespace.Container: BlockContainerModelProtocol {
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
    func children(of id: BlockId) -> [BlockId] {
        if let value = self._models[id] {
            return value.information.childrenIds
        }
        return []
    }
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlockActiveRecordModelProtocol? {
        self._choose(by: id)
    }
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlockModelProtocol? {
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
    func add(_ block: BlockModelProtocol) {
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
    
}

extension Namespace {
    final class ActiveRecord {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias NestedModel = BlockModel
        private weak var _container: Container?
        private var _nestedModel: NestedModel
        init(container: Container, chosenBlock: NestedModel) {
            self._container = container
            self._nestedModel = chosenBlock
        }
        required init(_ chosen: ActiveRecord) {
            self._container = chosen._container
            self._nestedModel = chosen._nestedModel
        }
        class func create(_ chosen: ActiveRecord) -> Self {
            .init(chosen)
        }
    }
}

extension Namespace.ActiveRecord: ObservableObject, BlockActiveRecordModelProtocol {
    var container: BlockContainerModelProtocol? {
        self._container
    }
    
    var blockModel: BlockModelProtocol {
        self._nestedModel
    }
    
    static var defaultIndentationLevel: Int { -1 }
    var indentationLevel: Int {
        if self.isRoot {
            return Self.defaultIndentationLevel
        }

        guard let parentId = self._nestedModel.parent else { return Self.defaultIndentationLevel }
        guard let parent = self._container?._choose(by: parentId) else { return Self.defaultIndentationLevel }
        switch self._nestedModel.kind {
        case .meta: return parent.indentationLevel
        case .block: return parent.indentationLevel + 1
        }
    }
    
    var isRoot: Bool {
        self._nestedModel.parent == nil
    }
    
    func findParent() -> Self? {
        if self.isRoot {
            return nil
        }

        guard let parentId = self._nestedModel.parent else { return nil }
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
            self.container?.userSession.isFirstResponder(by: self._nestedModel.information.id) ?? false
        }
        set {
            self.container?.userSession.setFirstResponder(by: self._nestedModel.information.id)
        }
    }
    
    func unsetFirstResponder() {
        if self.isFirstResponder {
            self.container?.userSession.unsetFirstResponder()
        }
    }
    
    var isToggled: Bool {
        get {
            self.container?.userSession.isToggled(by: self._nestedModel.information.id) ?? false
        }
        set {
            self.container?.userSession.setToggled(by: self._nestedModel.information.id, value: newValue)
        }
    }
    
    var focusAt: Position? {
        get {
            guard self.container?.userSession.firstResponder() == self._nestedModel.information.id else { return nil }
            return self.container?.userSession.focusAt()
        }
        set {
            guard self.container?.userSession.firstResponder() == self._nestedModel.information.id else { return }
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
    
    func didChangeInformationPublisher() -> AnyPublisher<BlockInformationModelProtocol, Never> { self.blockModel.didChangeInformationPublisher() }
}
