import Foundation

public enum IndentationBuilder {
    public static func build(container: InfoContainerProtocol, id: BlockId) {
        privateBuild(container: container, id: id)
    }

    private static func privateBuild(
        container: InfoContainerProtocol,
        id: BlockId
    ) {
        if let parent = container.get(id: id) {
            var updatedBlockNumber = 0

            parent.childrenIds.forEach { childrenId in
                guard let child = container.get(id: childrenId) else { return }

                let updatedMetadataChild = child.updated(
                    metadata: BlockInformationMetadata(
                        parentId: parent.id,
                        backgroundColor: child.backgroundColor
                    )
                )


                let updatedChild = updatedNumberedValueIfNeeded(
                    container: container,
                    child: updatedMetadataChild,
                    numberValue: &updatedBlockNumber
                )

                if child != updatedChild {
                    container.add(updatedChild)
                }

                privateBuild(
                    container: container,
                    id: childrenId
                )
            }
        }
    }

    
    private static func updatedNumberedValueIfNeeded(
        container: InfoContainerProtocol,
        child: BlockInformation,
        numberValue: inout Int
    ) -> BlockInformation {
        switch child.content {
        case let .text(text) where text.contentType == .numbered:
            numberValue += 1
            let content = BlockContent.text(text.updated(number: numberValue))

            return child.updated(content: content)
        default:
            numberValue = 0
        }

        return child
    }

   
}

