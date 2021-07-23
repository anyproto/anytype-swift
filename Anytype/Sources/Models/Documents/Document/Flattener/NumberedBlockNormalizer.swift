import BlocksModels

/// Check numbered blocks that it has correct number in numbered list.
final class NumberedBlockNormalizer: BlockChildrenNormalizer {
    func normalize(_ ids: [BlockId], in container: RootBlockContainer) {
        var number: Int = 0
        for id in ids {
            if let model = container.blocksContainer.record(id: id) {
                switch model.content {
                case let .text(value) where value.contentType == .numbered:
                    number += 1
                    var blockModel = model.blockModel
                    blockModel.information.content = .text(.init(attributedText: value.attributedText, color: value.color, contentType: value.contentType, checked: value.checked, number: number))
                default: number = 0
                }
            }
        }
    }
}
