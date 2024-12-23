import Foundation
import Combine
import AnytypeCore

public final class InfoContainer: InfoContainerProtocol, Sendable {
    
    private let models = SynchronizedDictionary<String, BlockInformation>()
    public init() {}
    
    public func children(of id: String) -> [BlockInformation] {
        guard let information = models[id] else {
            return []
        }
        return information.childrenIds.compactMap { get(id: $0) }
    }

    public func recursiveChildren(of id: String) -> [BlockInformation] {
        guard let information = models[id] else { return [] }

        let childBlocks = information.childrenIds.compactMap { get(id: $0) }

        return childBlocks + childBlocks.map { recursiveChildren(of: $0.id) }.flatMap { $0 }
    }

    public func get(id: String) -> BlockInformation? {
        models[id]
    }
    
    public func add(_ info: BlockInformation) {
        models[info.id] = info
    }

    public func remove(id: String) {
        // go to parent and remove this block from a parent.
        if let parentId = get(id: id)?.configurationData.parentId, let parent = models[parentId] {
            let childrenIds = parent.childrenIds.filter {$0 != id}
            add(parent.updated(childrenIds: childrenIds))
        }
        
        models.removeValue(forKey: id)
    }

    public func setChildren(ids: [String], parentId: String) {
        guard let parent = get(id: parentId) else {
            anytypeAssertionFailure("I can't find entry", info: ["parentId": parentId])
            return
        }
        
        add(parent.updated(childrenIds: ids))
    }
    
    public func update(blockId: String, update updateAction: (BlockInformation) -> (BlockInformation?)) {
        guard let entry = get(id: blockId) else {
            anytypeAssertionFailure("No block", info: ["blockId": blockId])
            return
        }
        
        updateAction(entry).flatMap { add($0) }
    }
}
