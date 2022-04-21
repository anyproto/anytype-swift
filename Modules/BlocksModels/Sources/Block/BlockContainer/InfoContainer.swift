import Foundation
import Combine
import AnytypeCore

public final class InfoContainer: InfoContainerProtocol {
    
    private var models = SynchronizedDictionary<BlockId, BlockInformation>()
    
    public init() {}
    
    public func children(of id: BlockId) -> [BlockInformation] {
        guard let information = models[id] else {
            return []
        }
        
        return information.childrenIds.compactMap { get(id: $0.value) }
    }

    public func recursiveChildren(of id: BlockId) -> [BlockInformation] {
        guard let information = models[id] else { return [] }

        let childBlocks = information.childrenIds.compactMap { get(id: $0.value) }

        return childBlocks + childBlocks.map { recursiveChildren(of: $0.id.value) }.flatMap { $0 }
    }

    public func get(id: BlockId) -> BlockInformation? {
        models[id]
    }
    
    public func add(_ info: BlockInformation) {
        models[info.id.value] = info
    }

    public func remove(id: BlockId) {
        // go to parent and remove this block from a parent.
        if let parentId = get(id: id)?.configurationData.parentId, let parent = models[parentId] {
            let childrenIds = parent.childrenIds.filter {$0.value != id}
            add(parent.updated(childrenIds: childrenIds))
        }
        
        models.removeValue(forKey: id)
    }

    public func setChildren(ids: [BlockId], parentId: BlockId) {
        guard let parent = get(id: parentId) else {
            anytypeAssertionFailure("I can't find entry with id: \(parentId)", domain: .blockContainer)
            return
        }
        
        let anytypeIds = ids.compactMap { $0.asAnytypeId }

        add(parent.updated(childrenIds: anytypeIds))
    }
    
    public func update(blockId: BlockId, update updateAction: @escaping (BlockInformation) -> (BlockInformation?)) {
        guard let entry = get(id: blockId) else {
            anytypeAssertionFailure("No block with id \(blockId)", domain: .blockContainer)
            return
        }
        
        updateAction(entry).flatMap { add($0) }
    }
    
    public func updateDataview(blockId: BlockId, update updateAction: @escaping (BlockDataview) -> (BlockDataview)) {
        update(blockId: blockId) { info in
            guard case let .dataView(dataView) = info.content else {
                anytypeAssertionFailure(
                    "\(info.content) not a dataview in \(info)",
                    domain: .blockContainer
                )
                return nil
            }
            
            let content = BlockContent.dataView(updateAction(dataView))
            return info.updated(content: content)
        }
    }
}
