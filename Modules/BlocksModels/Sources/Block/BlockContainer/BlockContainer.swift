import Foundation
import Combine
import AnytypeCore

public final class BlockContainer: BlockContainerModelProtocol {
    
    private var models = SynchronizedDictionary<BlockId, BlockInformation>()

    public var rootId: BlockId?
    
    public init() {}
    
    public func children(of id: BlockId) -> [BlockInformation] {
        guard let information = models[id] else {
            return []
        }
        
        return information.childrenIds.compactMap { model(id: $0) }
    }

    public func model(id: BlockId) -> BlockInformation? {
        models[id]
    }

    public func remove(_ id: BlockId) {
        // go to parent and remove this block from a parent.
        if let parentId = model(id: id)?.metadata.parentId,
           var parent = models[parentId] {
            parent.childrenIds = parent.childrenIds.filter {$0 != id}
            add(parent)
        }
        
        if let information = model(id: id) {
            models.removeValue(forKey: id)
            information.childrenIds.forEach(remove(_:))
        }
    }

    public func add(_ info: BlockInformation) {
        models[info.id] = info
    }

    private func insert(childId: BlockId, parentId: BlockId, at index: Int) {
        guard var parent = model(id: parentId) else {
            anytypeAssertionFailure("I can't find parent with id: \(parentId)", domain: .blockContainer)
            return
        }
        
        guard var child = model(id: childId) else {
            anytypeAssertionFailure("I can't find child with id: \(childId)", domain: .blockContainer)
            return
        }
        
        var childrenIds = parent.childrenIds
        childrenIds.insert(childId, at: index)
        parent.childrenIds = childrenIds
        add(parent)
        
        /// And now set parent
        child.metadata.parentId = parent.id
        add(child)
    }

    public func add(child: BlockId, beforeChild: BlockId) {
        /// First, we must find parent of beforeChild
        guard let parentId = model(id: beforeChild)?.metadata.parentId,
              let parent = model(id: parentId),
              let index = parent.childrenIds.firstIndex(of: beforeChild)
        else {
            anytypeAssertionFailure(
                "I can't find either parent or block itself with id: \(beforeChild)",
                domain: .blockContainer
            )
            return
        }

        self.insert(childId: child, parentId: parent.id, at: index)
    }

    public func add(child: BlockId, afterChild: BlockId) {
        /// First, we must find parent of afterChild
        guard let parentId = model(id: afterChild)?.metadata.parentId,
              let parent = model(id: parentId),
              let index = parent.childrenIds.firstIndex(of: afterChild)
        else {
            anytypeAssertionFailure(
                "I can't find either parent or block itself with id: \(afterChild)",
                domain: .blockContainer
            )
            return
        }

        let newIndex = index.advanced(by: 1)
        insert(childId: child, parentId: parent.id, at: newIndex)
    }
    
    public func update(blockId: BlockId, update updateAction: @escaping (BlockInformation) -> (BlockInformation?)) {
        guard let entry = model(id: blockId) else {
            anytypeAssertionFailure("No block with id \(blockId)", domain: .blockContainer)
            return
        }
        
        updateAction(entry).flatMap { add($0) }
    }
    
    public func updateDataview(blockId: BlockId, update updateAction: @escaping (BlockDataview) -> (BlockDataview)) {
        update(blockId: blockId) { info in
            var info = info
            guard case let .dataView(dataView) = info.content else {
                anytypeAssertionFailure(
                    "\(info.content) not a dataview in \(info)",
                    domain: .blockContainer
                )
                return nil
            }
            
            info.content = .dataView(updateAction(dataView))
            return info
        }
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
    public func replace(
        childrenIds: [BlockId],
        parentId: BlockId,
        shouldSkipGuardAgainstMissingIds: Bool = false
    ) {
        
        guard var parent = model(id: parentId) else {
            anytypeAssertionFailure("I can't find entry with id: \(parentId)", domain: .blockContainer)
            return
        }
                
        let existedIds = !shouldSkipGuardAgainstMissingIds ? childrenIds.filter { (childId) in
            if model(id: childId) != nil {
                return true
            }
            else {
                anytypeAssertionFailure("I can't find entry with id: \(parentId)", domain: .blockContainer)
                return false
            }
        } : childrenIds

        parent.childrenIds = existedIds
        add(parent)
    }    
}
