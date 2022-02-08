import BlocksModels


/// ```
/// Input:
/// A -> [B, C, D]
///
/// B -> [X]
/// C -> [Y]
/// D -> [Z]
/// ```
///
/// ```
/// Result: [A, B, X, C, Y, D, Z]
/// ```
/// It is like a left-order traversing of tree, but we have to output parents first.
///
final class BlockFlattener {
            
    static func flatten(
        model: BlockModelProtocol, container: BlockContainerModelProtocol
    ) -> [BlockModelProtocol] {
        let ids = flattenIds(model: model, container: container)
        return ids.compactMap { container.model(id: $0) }
    }
    
    static func flattenIds(
        model: BlockModelProtocol, container: BlockContainerModelProtocol
    ) -> [BlockId] {
        /// Fix it.
        /// Because `ShouldKeep` template method will flush out all unnecessary blocks from list.
        /// There is no need to skip first block ( or parent block ) if it is already skipped by `ShouldKeep`.
        ///
        /// But for any other parent block it will work properly.
        ///
        let rootItemIsAlreadySkipped = !self.shouldKeep(blockId: model.information.id, blocksContainer: container)
        
        let flattenIds = _flatten(model: model, container: container)
        
        if rootItemIsAlreadySkipped {
            return flattenIds
        }
        else {
            return Array(flattenIds.dropFirst())
        }
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
            return processedToggle(blockId: blockId, container: container)
        default:
            return container.children(of: blockId)
        }
    }
    
    static func _flatten(model: BlockModelProtocol, container: BlockContainerModelProtocol) -> [BlockId] {
        var result = Array<BlockId>()
        let stack = Stack<BlockId>()
        stack.push(model.information.id)
        
        while !stack.isEmpty {
            if let value = stack.pop() {
                /// Various flatteners?
                if self.shouldKeep(blockId: value, blocksContainer: container) {
                    result.append(value)
                }
                
                /// Do numbered stuff?
                let children = filteredChildren(blockId: value, container: container)
                NumberedBlockNormalizer().normalize(children, in: container)
                for item in children.reversed() {
                    stack.push(item)
                }
            }
        }
        return result
    }
    
    static func processedToggle(blockId: BlockId, container: BlockContainerModelProtocol) -> [BlockId] {
        let isToggled = UserSession.shared.isToggled(blockId: blockId)
        if isToggled {
            return container.children(of: blockId)
        }
        else {
            return []
        }
    }
}
