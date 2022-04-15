import AnytypeCore

/// Input:
/// A -> [B, C, D]
/// B -> [X]
/// C -> [Y]
/// D -> [Z]
///
/// Result: [A, B, X, C, Y, D, Z]
/// It is like a left-order traversing of tree, but we have to output parents first.
///
final class ChildrenInfoTreeBuilder {
    private let container: InfoContainerProtocol
    private let root: BlockInformation
    init(container: InfoContainerProtocol, root: BlockInformation) {
        self.container = container
        self.root = root
    }
            
    func flatList() -> [BlockInformation] {
        var result = Array<BlockInformation>()
        let stack = Stack<BlockInformation>()
        
        stack.push(root)
        
        while !stack.isEmpty {
            if let info = stack.pop() {
                if info.kind == .block { result.append(info) } // Skip meta blocks
                
                let children = findChildren(info: info)
                updateBlockNumberCount(infos: children)
                
                for item in children.reversed() {
                    stack.push(item)
                }
            }
        }
        
        return result
    }

    private func findChildren(info: BlockInformation) -> [BlockInformation] {
        if info.content.isToggle, ToggleStorage.shared.isToggled(blockId: info.id.value) == false {
            return [] // return no children for closed toggle
        }
        
        return container.children(of: info.id.value)
    }
    
    private func updateBlockNumberCount(infos: [BlockInformation]) {
        var number: Int = 0
        
        infos.forEach { info in
            switch info.content {
            case let .text(text) where text.contentType == .numbered:
                number += 1
                let content = BlockContent.text(text.updated(number: number))
                container.add(info.updated(content: content))
            default:
                number = 0
            }
        }
    }
}
