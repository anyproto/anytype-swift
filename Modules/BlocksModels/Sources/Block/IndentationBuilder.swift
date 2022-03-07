import Foundation

public enum IndentationBuilder {
    public static func build(container: BlockContainerModelProtocol, id: BlockId) {
        if let parent = container.model(id: id) {
            parent.childrenIds.forEach { childrenId in
                guard var child = container.model(id: childrenId) else { return }

                child.metadata.parentId = parent.id
                child.metadata.indentationLevel = 0

                // Don't count indentation if parent or child is meta(not drawing) block
                if parent.kind != .meta, child.kind != .meta {
                    child.metadata.indentationLevel = parent.metadata.indentationLevel + 1
                }

                container.add(child)
                build(container: container, id: childrenId)
            }
        }
    }

}
