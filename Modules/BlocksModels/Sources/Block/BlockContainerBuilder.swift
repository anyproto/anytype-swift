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
        if let entry = container.record(id: id) {
            let parentId = id
            entry.childrenIds().forEach { (value) in
                var blockModel = entry.findChild(by: value)?.blockModel
                blockModel?.parent = parentId
                self.buildTree(container: container, id: value)
            }
        }
    }

}
