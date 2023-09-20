import AnytypeCore
import Foundation
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

                for item in children.reversed() {
                    stack.push(item)
                }
            }
        }
        
        return result
    }
//    func treeList(root: TreeList<BlockInformation>) -> [TreeList<BlockInformation>] {
//        var result: TreeList<BlockInformation>?
//        let stack = Stack<BlockInformation>()
//
//        let children = findChildren(info: root.value)
//        for item in children.reversed() {
//            stack.push(item)
//        }
//        
//        stack.push(root.value)
//
//        while !stack.isEmpty {
//            if let info = stack.pop() {
//                guard info.kind == .block else {
//                    continue
//                }  // Skip meta blocks
//
//                result = .init(value: info, children: children)
//            }
//        }
//
//        return result
//    }

    private func findChildren(info: BlockInformation) -> [BlockInformation] {
        switch info.content {
        case .tableRow, .tableColumn:
            return []
        default: break
        }
        
        if info.content.isToggle, ToggleStorage.shared.isToggled(blockId: info.id) == false {
            return [] // return no children for closed toggle
        }
        
        return container.children(of: info.id)
    }
}

public final class TreeList<T> {
    
    var value: T
    var children: [TreeList<T>]
    
    internal init(value: T, children: [TreeList<T>]) {
        self.value = value
        self.children = children
    }
}

//
//extension Array where Element == BlockInformation {
//    var treeList: [TreeList<BlockInformation>] {
//        let listTree = Array<TreeList<BlockInformation>>()
//
//        var skippedBlockIds = [BlockId]()
//
//        for child in self {
//
//        }
//    }
//}

