
import BlocksModels


///
/// # Abstract
/// Algorithm is
/// "Put on stack in backwards order."
///
/// ## Why does it work?
///
/// Consider that you have the following structure
///
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
///
/// It is like a left-order traversing of tree, but we have to output parents first.
/// It is like a DFS, but again, we would like to output parents first.
///
/// Our Solution:
///
/// ```
/// 1. Stack = Init
/// 2. A -> Stack [A]
/// 3. While NotEmpty(Stack)
/// 3. Value <- Stack []
/// 4. Value -> Solution (A)
/// 5. Children(Value).Reversed -> Stack [B, C, D] /// Look carefully.
/// 6. Repeat.
/// ```
///
final class BlockFlattener {
            
    /// Returns flat list of nested data starting from model at root ( node ) and moving down through a list of its children.
    /// It is like a "opening all nested folders" in a parent folder.
    /// - Parameters:
    ///   - model: Model ( or Root ) from which we would like to start.
    ///   - container: A container in which we will find items.
    ///   - options: Options for flattening strategies.
    /// - Returns: A list of active models.
    static func flatten(
        root model: BlockModelProtocol,
        in blocksContainer: BlockContainerModelProtocol,
        options: BlockFlattenerOptions
    ) -> [BlockModelProtocol] {
        let ids = flattenIds(
            root: model,
            in: blocksContainer,
            options: options
        )
        return ids.compactMap { blocksContainer.model(id: $0) }
    }
    
    /// Returns flat list of nested data starting from model at root ( node ) and moving down through a list of its children.
    /// It is like a "opening all nested folders" in a parent folder.
    /// - Parameters:
    ///   - model: Model ( or Root ) from which we would like to start.
    ///   - container: A container in which we will find items.
    ///   - options: Options for flattening strategies.
    /// - Returns: A list of block ids.
    @discardableResult
    static func flattenIds(
        root model: BlockModelProtocol,
        in blocksContainer: BlockContainerModelProtocol,
        options: BlockFlattenerOptions
    ) -> [BlockId] {
        /// Fix it.
        /// Because `ShouldKeep` template method will flush out all unnecessary blocks from list.
        /// There is no need to skip first block ( or parent block ) if it is already skipped by `ShouldKeep`.
        ///
        /// But for any other parent block it will work properly.
        ///
        let rootItemIsAlreadySkipped = !self.shouldKeep(
            item: model.information.id,
            in: blocksContainer
        )
        if options.shouldIncludeRootNode || rootItemIsAlreadySkipped {
            return self.flatten(
                root: model,
                in: blocksContainer,
                options: options
            )
        }
        else {
            return Array(
                self.flatten(
                    root: model,
                    in: blocksContainer,
                    options: options
                ).dropFirst()
            )
        }
    }
}

// MARK: - Helpers
private extension BlockFlattener {
    /// Template method.
    /// If you would like to keep item in result list of blocks, you should return true.
    /// - Parameters:
    ///   - item: Id of current item.
    ///   - container: Container.
    /// - Returns: A condition if we would like to keep item in list.
    static func shouldKeep(
        item: BlockId,
        in blocksContainer: BlockContainerModelProtocol
    ) -> Bool {
        guard let model = blocksContainer.model(id: item) else {
            return false
        }
        switch model.information.content {
        case .smartblock, .layout: return false
        default: return true
        }
    }
    
    
    /// Template method.
    /// If we would like to filter children somehow, we could do it here.
    /// - Parameters:
    ///   - item: Id of current item.
    ///   - container: Container.
    ///   - shouldCheckIsToggleOpened: Should check opened state for toggle bocks
    /// - Returns: Filtered children of an item.
    static func filteredChildren(
        of item: BlockId,
        in blocksContainer: BlockContainerModelProtocol,
        shouldCheckIsToggleOpened: Bool
    ) -> [BlockId] {
        guard let model = blocksContainer.model(id: item) else {
            return []
        }
        switch model.information.content {
        case let .text(value) where value.contentType == .toggle:
            return ToggleFlattener(
                shouldCheckToggleFlag: shouldCheckIsToggleOpened
            ).processedChildren(
                item,
                in: blocksContainer
            )
        default:
            return blocksContainer.children(of: item)
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
                if self.shouldKeep(item: value, in: blocksContainer) {
                    result.append(value)
                }
                
                /// Do numbered stuff?
                let children = self.filteredChildren(
                    of: value,
                    in: blocksContainer,
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
}
