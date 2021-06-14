import Foundation
import Combine

public protocol BlockActiveRecordModelProtocol: BlockHasDidChangePublisherProtocol {
    var container: BlockContainerModelProtocol? {get}
    var blockModel: BlockModelProtocol {get}

    var indentationLevel: Int {get}

    var isRoot: Bool {get}

    func findParent() -> Self?
    func findRoot() -> Self?

    func childrenIds() -> [BlockId]
    func findChild(by id: BlockId) -> Self?

    var isFirstResponder: Bool {get set}
    func unsetFirstResponder()

    var isToggled: Bool {get set}

    var focusAt: BlockFocusPosition? {get set}
}

public extension BlockActiveRecordModelProtocol {
    mutating func unsetFocusAt() { self.focusAt = nil }
    
    var content: BlockContent {
        blockModel.information.content
    }
    
    var blockId: BlockId {
        blockModel.information.id
    }
}

public extension BlockActiveRecordModelProtocol {
    var isTextAndEmpty: Bool {
        switch blockModel.information.content {
        case .text(let textData):
            return textData.attributedText.string.isEmpty
        default:
            return false
        }
    }
}
