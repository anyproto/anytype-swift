import Foundation
import Combine
import AnytypeCore

public final class BlockContainer: BlockContainerModelProtocol {
    
    private var models = SynchronizedDictionary<BlockId, BlockInformation>()
    
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
    
    public func add(_ info: BlockInformation) {
        models[info.id] = info
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
    
    public func set(childrenIds: [BlockId], parentId: BlockId) {
        guard var parent = model(id: parentId) else {
            anytypeAssertionFailure("I can't find entry with id: \(parentId)", domain: .blockContainer)
            return
        }

        parent.childrenIds = childrenIds
        add(parent)
    }
}
