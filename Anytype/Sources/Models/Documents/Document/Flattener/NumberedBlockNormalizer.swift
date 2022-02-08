import BlocksModels

/// Check numbered blocks that it has correct number in numbered list.
final class NumberedBlockNormalizer {

    func normalize(_ ids: [BlockId], in blocksContainer: BlockContainerModelProtocol) {
        var number: Int = 0
        
        for id in ids {
            if var blockModel = blocksContainer.model(id: id) {
                switch blockModel.information.content {
                case let .text(value) where value.contentType == .numbered:
                    number += 1
                    
                    blockModel.information.content = .text(
                        .init(
                            text: value.text,
                            marks: value.marks,
                            color: value.color,
                            contentType: value.contentType,
                            checked: value.checked,
                            number: number
                        )
                    )
                default: number = 0
                }
            }
        }
    }
}
