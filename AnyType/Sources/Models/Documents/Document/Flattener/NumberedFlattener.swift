import BlocksModels

/// Flattener to set numbers for numbered blocks
final class NumberedFlattener {
    
    /// Change content of  children with ids
    ///
    /// - Parameters:
    ///   - ids: Children ids to change
    ///   - container: Container with all blocks
    func process(_ ids: [BlockId], in container: ContainerModel) {
        var number: Int = 0
        for id in ids {
            if let model = container.blocksContainer.choose(by: id) {
                switch model.blockModel.information.content {
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
