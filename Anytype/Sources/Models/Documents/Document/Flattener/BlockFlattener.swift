import BlocksModels


/// Input:
/// A -> [B, C, D]
/// B -> [X]
/// C -> [Y]
/// D -> [Z]
///
/// Result: [A, B, X, C, Y, D, Z]
/// It is like a left-order traversing of tree, but we have to output parents first.
///
final class BlockFlattener {
    private let container: BlockContainerModelProtocol
    init(container: BlockContainerModelProtocol) {
        self.container = container
    }
            
    func flatten(model: BlockModelProtocol) -> [BlockModelProtocol] {
        var result = Array<BlockModelProtocol>()
        let stack = Stack<BlockModelProtocol>()
        
        stack.push(model)
        
        while !stack.isEmpty {
            if let model = stack.pop() {
                // Skip meta blocks
                if model.kind == .block { result.append(model) }
                
                let children = children(model: model)
                
                normalizeBlockNumber(blocks: children)
                for item in children.reversed() {
                    stack.push(item)
                }
            }
        }
        
        return result
    }

    private func children(model: BlockModelProtocol) -> [BlockModelProtocol] {
        if model.information.content.isToggle, UserSession.shared.isToggled(blockId: model.information.id) == false {
            return [] // return no children for closed toggle
        }
        
        return container.children(of: model.information.id)
    }
    
    /// Check numbered blocks that it has correct number in numbered list.
    func normalizeBlockNumber(blocks: [BlockModelProtocol]) {
        var number: Int = 0
        
        for blockModel in blocks {
            switch blockModel.information.content {
            case let .text(value) where value.contentType == .numbered:
                number += 1
                var blockModel = blockModel
                
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
