import Foundation

public enum IndentationBuilder {
    public static func build(container: BlockContainerModelProtocol, id: BlockId) {
        if let parentBlock = container.model(id: id) {
            parentBlock.information.childrenIds.forEach { childrenId in
                guard var childBlock = container.model(id: childrenId) else { return }

                childBlock.information.metadata.parentId = parentBlock.information.id
                childBlock.information.metadata.indentationLevel = 0

                // Don't count indentation if parent or child is meta(not drawing) block
                if parentBlock.information.kind != .meta, childBlock.information.kind != .meta {
                    childBlock.information.metadata.indentationLevel = parentBlock.information.metadata.indentationLevel + 1
                }

                build(container: container, id: childrenId)
            }
        }
    }

}
