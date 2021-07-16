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
    
    private static func buildTreeRecursively(container: BlockContainerModelProtocol, id: BlockId) {
        if let entry = container.record(id: id) {
            let parentId = id
            entry.childrenIds().forEach { (value) in
                var blockModel = entry.findChild(by: value)?.blockModel
                blockModel?.parent = parentId
                self.buildTreeRecursively(container: container, id: value)
            }
        }
    }
    
    public static func buildTree(container: BlockContainerModelProtocol, rootId: String?) {
        if let rootId = rootId {
            self.buildTreeRecursively(container: container, id: rootId)
        }
        else {
            assertionFailure("Can't build tree. RootId is nil")
        }
    }
}
