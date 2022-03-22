import Foundation

public enum IndentationBuilder {
    public static func build(container: InfoContainerProtocol, id: BlockId) {
        if let parent = container.get(id: id) {
            parent.childrenIds.forEach { childrenId in
                guard var child = container.get(id: childrenId) else { return }
                
                let indentationLevel: Int
                // Don't count indentation if parent or child is meta(not drawing) block
                if parent.kind != .meta, child.kind != .meta {
                    indentationLevel = parent.metadata.indentationLevel + 1
                } else {
                    indentationLevel = 0
                }
                
                child = child.updated(
                    metadata: BlockInformationMetadata(
                        indentationLevel: indentationLevel,
                        parentId: parent.id
                    )
                )

                container.add(child)
                build(container: container, id: childrenId)
            }
        }
    }

}
