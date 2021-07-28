import Foundation
import os

public enum BlockContainerBuilder {
    public static func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol {
        let container = BlockContainer()
        list.forEach(container.add(_:))
        return container
    }
    
    public static func emptyContainer() -> BlockContainerModelProtocol {
        build(list: [])
    }
    
    public static func buildTree(container: BlockContainerModelProtocol, id: BlockId) {
        if let entry = container.model(id: id) {
            entry.information.childrenIds.forEach { childrenId in
                var blockModel = container.model(id: childrenId)
                blockModel?.parent = entry
                blockModel?.indentationLevel = 0
                
                if entry.kind != .meta, blockModel?.kind != .meta {
                    blockModel?.indentationLevel = entry.indentationLevel + 1
                }
                self.buildTree(container: container, id: childrenId)
            }
        }
    }

}
