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
            
    static func flatten(
        model: BlockModelProtocol, container: BlockContainerModelProtocol
    ) -> [BlockModelProtocol] {
        let ids = _flatten(model: model, container: container)
        return ids.compactMap { container.model(id: $0) }
    }
}

// MARK: - Helpers
private extension BlockFlattener {
    static func shouldKeep(blockId: BlockId, blocksContainer: BlockContainerModelProtocol) -> Bool {
        guard let model = blocksContainer.model(id: blockId) else { return false }
        return model.kind == .block
    }
    
    static func filteredChildren(blockId: BlockId, container: BlockContainerModelProtocol) -> [BlockId] {
        guard let model = container.model(id: blockId) else { return [] }
        
        switch model.information.content {
        case let .text(value) where value.contentType == .toggle:
            return toggleChildren(blockId: blockId, container: container)
        default:
            return container.childrenIds(of: blockId)
        }
    }
    
    static func _flatten(model: BlockModelProtocol, container: BlockContainerModelProtocol) -> [BlockId] {
        var result = Array<BlockId>()
        let stack = Stack<BlockId>()
        stack.push(model.information.id)
        
        while !stack.isEmpty {
            if let value = stack.pop() {
                if self.shouldKeep(blockId: value, blocksContainer: container) {
                    result.append(value)
                }
                
                let children = filteredChildren(blockId: value, container: container)
                normalizeBlockNumber(blockIds: children, container: container)
                for item in children.reversed() {
                    stack.push(item)
                }
            }
        }
        
        return result
    }
    
    static func toggleChildren(blockId: BlockId, container: BlockContainerModelProtocol) -> [BlockId] {
        let isToggled = UserSession.shared.isToggled(blockId: blockId)
        if isToggled {
            return container.childrenIds(of: blockId)
        }
        else {
            return []
        }
    }
    
    /// Check numbered blocks that it has correct number in numbered list.
    static func normalizeBlockNumber(blockIds: [BlockId], container: BlockContainerModelProtocol) {
        var number: Int = 0
        
        for id in blockIds {
            if var blockModel = container.model(id: id) {
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
