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
        if let parentBlock = container.model(id: id) {
            parentBlock.information.childrenIds.forEach { childrenId in
                var childBlock = container.model(id: childrenId)
                childBlock?.parent = parentBlock
                childBlock?.indentationLevel = 0

                // Don't count indentation if parent or child is meta(not drawing) block
                if parentBlock.kind != .meta, childBlock?.kind != .meta {
                    childBlock?.indentationLevel = parentBlock.indentationLevel + 1
                }
                self.buildTree(container: container, id: childrenId)
            }
        }
    }

}
