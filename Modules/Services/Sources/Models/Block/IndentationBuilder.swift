import Foundation

public enum IndentationBuilder {
    public static func build(container: InfoContainerProtocol, id: String) -> [String] {
        var numberValue = 0
        return privateBuild(container: container, numberValue: &numberValue, id: id)
    }

    private static func privateBuild(
        container: InfoContainerProtocol,
        numberValue: inout Int,
        id: String
    ) -> [String] {
        var changedIds = [String]()
        if let parent = container.get(id: id) {

            parent.childrenIds.forEach { childrenId in
                
                guard let child = container.get(id: childrenId) else { return }
                
                let updatedMetadataChild = child.updated(
                    metadata: BlockInformationMetadata(
                        parentId: parent.id,
                        backgroundColor: child.backgroundColor
                    )
                )


                let updatedChild = updatedNumberedValueIfNeeded(
                    child: updatedMetadataChild,
                    numberValue: &numberValue
                )

                if child != updatedChild {
                    container.add(updatedChild)
                    changedIds.append(childrenId)
                }
                
                // Don't reset value between parent-child for div
                // Example.
                // div(1)
                //   text num
                //   text num <- Copy this value to next parent div(2)
                // div(2) <- Use value here
                //   text num
                //   text num
                let useNumberFromParent = child.content == BlockContent.layout(BlockLayout(style: .div))
                var childNumberValue = useNumberFromParent ? numberValue : 0

                let childChangesIds = privateBuild(
                    container: container,
                    numberValue: &childNumberValue,
                    id: childrenId
                )
                
                changedIds.append(contentsOf: childChangesIds)
                
                if useNumberFromParent {
                    numberValue = childNumberValue
                }
            }
        }
        return changedIds
    }
    
    private static func updatedNumberedValueIfNeeded(
        child: BlockInformation,
        numberValue: inout Int
    ) -> BlockInformation {
        switch child.content {
        case let .text(text) where text.contentType == .numbered:
            numberValue += 1
            let content = BlockContent.text(text.updated(number: numberValue))

            return child.updated(content: content)
        // Ignore reset value between items in one level.
        // Example. Two div, but there are one numeric list.
        // div(2) <- This item contains text num(2) value
        //   text num(1)
        //   text num(2)
        // div(3) <- This item using div(1) final num value for child items.
        //   text num(3)
        //   text num(4)
        case let .layout(style) where style == BlockLayout(style: .div):
            break
        default:
            numberValue = 0
        }

        return child
    }

   
}

