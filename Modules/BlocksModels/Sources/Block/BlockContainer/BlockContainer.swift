import Foundation
import Combine
import os

final class BlockContainer {
    private var _rootId: BlockId?
    private var _models: [BlockId: BlockModel] = [:]
    private var _userSession = UserSession()
    
    func _choose(by id: BlockId) -> BlockActiveRecord? {
        if let value = self._models[id] {
            return .init(container: self, chosenBlock: value)
        }
        else {
            return nil
        }
    }
                    
    private func _get(by id: BlockId) -> BlockModel? {
        self._models[id]
    }
    
    private func _add(_ block: BlockModel) {
        if self._models[block.information.id] != nil {
            assertionFailure("We shouldn't replace block by add operation. Skipping...")
            return
        }
        self._models[block.information.id] = block
    }
}

extension BlockContainer: BlockContainerModelProtocol {
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
    func choose(by id: BlockId) -> BlockActiveRecordProtocol? {
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
        let blockModel: BlockModel = .init(information: block.information)
        blockModel.parent = block.parent
        self._add(blockModel)
    }
    // MARK: - Children / Append
    func append(childId: BlockId, parentId: BlockId) {
        guard let child = choose(by: childId) else {
            assertionFailure("I can't find entry with id: \(parentId)")
            return
        }
        guard let parent = choose(by: parentId) else {
            assertionFailure("I can't find entry with id: \(parentId)")
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
            assertionFailure("I can't find parent with id: \(parentId)")
            return
        }
        
        guard var childModel = self.get(by: childId) else {
            assertionFailure("I can't find child with id: \(childId)")
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
            assertionFailure("I can't find either parent or block itself with id: \(beforeChild)")
            return
        }
        
        let parentId = parent.blockId
        
        self.insert(childId: child, parentId: parentId, at: index)
    }
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId) {
        /// First, we must find parent of afterChild
        guard let parent = self.choose(by: afterChild)?.findParent(), let index = parent.childrenIds().firstIndex(of: afterChild) else {
            assertionFailure("I can't find either parent or block itself with id: \(afterChild)")
            return
        }
        
        let parentId = parent.blockId
        
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
            assertionFailure("I can't find entry with id: \(parentId)")
            return
        }
                
        let existedIds = !shouldSkipGuardAgainstMissingIds ? childrenIds.filter { (childId) in
            if self.choose(by: childId) != nil {
                return true
            }
            else {
                assertionFailure("I can't find entry with id: \(parentId)")
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
