import Foundation
import os

public enum IndentationBuilder {
    public static func build(container: BlockContainerModelProtocol, id: BlockId) {
        if let parentBlock = container.model(id: id) {
            parentBlock.information.childrenIds.forEach { childrenId in
                guard var childBlock = container.model(id: childrenId) else { return }

                childBlock.parent = parentBlock
                childBlock.indentationLevel = 0

                // Don't count indentation if parent or child is meta(not drawing) block
                if parentBlock.kind != .meta, childBlock.kind != .meta {
                    childBlock.indentationLevel = parentBlock.indentationLevel + 1
                }

                build(container: container, id: childrenId)
            }
        }
    }

}
