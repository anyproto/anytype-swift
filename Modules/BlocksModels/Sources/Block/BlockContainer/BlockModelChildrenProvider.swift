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
final class BlockInfoChildrenProvider {
    private let container: InfoContainerProtocol
    init(container: InfoContainerProtocol) {
        self.container = container
    }
            
    func children(model: BlockInformation) -> [BlockInformation] {
        var result = Array<BlockInformation>()
        let stack = Stack<BlockInformation>()
        
        stack.push(model)
        
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
        if info.content.isToggle, ToggleStorage.shared.isToggled(blockId: info.id) == false {
            return [] // return no children for closed toggle
        }
        
        return container.children(of: info.id)
    }
    
    private func updateBlockNumberCount(infos: [BlockInformation]) {
        var number: Int = 0
        
        infos.forEach { info in
            switch info.content {
            case let .text(text) where text.contentType == .numbered:
                number += 1
                var info = info
                info.content = .text(text.updated(number: number))
                container.add(info)
            default:
                number = 0
            }
        }
    }
}
