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
        model: BlockModelProtocol, blocksContainer: BlockContainerModelProtocol, options: BlockFlattenerOptions
    ) -> [BlockModelProtocol] {
        let ids = flattenIds(model: model, blocksContainer: blocksContainer, options: options)
        return ids.compactMap { blocksContainer.model(id: $0) }
    }
    
    static func flattenIds(
        model: BlockModelProtocol, blocksContainer: BlockContainerModelProtocol,options: BlockFlattenerOptions
    ) -> [BlockId] {
        /// Fix it.
        /// Because `ShouldKeep` template method will flush out all unnecessary blocks from list.
        /// There is no need to skip first block ( or parent block ) if it is already skipped by `ShouldKeep`.
        ///
        /// But for any other parent block it will work properly.
        ///
        let rootItemIsAlreadySkipped = !self.shouldKeep(blockId: model.information.id, blocksContainer: blocksContainer)
        
        let flattenIds = flatten(root: model, in: blocksContainer, options: options)
        
        if options.shouldIncludeRootNode || rootItemIsAlreadySkipped {
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
        switch model.information.content {
        case .smartblock, .layout, .unsupported: return false
        case .text, .file, .divider, .bookmark, .link, .featuredRelations, .relation, .dataView:
            return true
        }
    }
    
    static func filteredChildren(
        blockId: BlockId, container: BlockContainerModelProtocol, shouldCheckIsToggleOpened: Bool
    ) -> [BlockId] {
        guard let model = container.model(id: blockId) else { return [] }
        
        switch model.information.content {
        case let .text(value) where value.contentType == .toggle:
            return processedToggle(blockId: blockId, container: container, shouldCheckToggleFlag: shouldCheckIsToggleOpened)
        default:
            return container.children(of: blockId)
        }
    }
    
    /// Returns flat list of nested data starting from model at root ( node ) and moving down through a list of its children.
    /// It is like a "opening all nested folders" in a parent folder.
    ///
    /// - Parameters:
    ///   - model: Model ( or Root ) from which we would like to start.
    ///   - container: A container in which we will find items.
    ///   - options: Options
    /// - Returns: A list of block ids.
    static func flatten(
        root model: BlockModelProtocol,
        in blocksContainer: BlockContainerModelProtocol,
        options: BlockFlattenerOptions
    ) -> [BlockId] {
        var result = Array<BlockId>()
        let stack = Stack<BlockId>()
        stack.push(model.information.id)
        var isInRootModel = true
        
        while !stack.isEmpty {
            if let value = stack.pop() {
                /// Various flatteners?
                if self.shouldKeep(blockId: value, blocksContainer: blocksContainer) {
                    result.append(value)
                }
                
                /// Do numbered stuff?
                let children = self.filteredChildren(
                    blockId: value,
                    container: blocksContainer,
                    shouldCheckIsToggleOpened: isInRootModel ? options.shouldCheckIsRootToggleOpened : true
                )
                options.normalizers.forEach {
                    $0.normalize(
                        children,
                        in: blocksContainer
                    )
                }
                for item in children.reversed() {
                    stack.push(item)
                }
                isInRootModel = false
            }
        }
        return result
    }
    
    static func processedToggle(
        blockId: BlockId,
        container: BlockContainerModelProtocol,
        shouldCheckToggleFlag: Bool
    ) -> [BlockId] {
        if !shouldCheckToggleFlag {
            return container.children(of: blockId)
        }
        
        let isToggled = UserSession.shared.toggles[blockId] ?? false
        if isToggled {
            return container.children(of: blockId)
        }
        else {
            return []
        }
    }
}
