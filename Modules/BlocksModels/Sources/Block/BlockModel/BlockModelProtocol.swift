import Foundation
import Combine

public protocol BlockModelProtocol {
    var information: BlockInformation { get set }
    init(information: BlockInformation)

    var container: BlockContainerModelProtocol? { get set }
    var parent: BlockModelProtocol? { get set }
    var kind: BlockKind { get }

    var indentationLevel: Int { get set }
    var isFirstResponder: Bool { get set }
    var isToggled: Bool { get }
    var focusAt: BlockFocusPosition? { get set }

    func toggle()
    func unsetFirstResponder()
}

public extension BlockInformation {
    var isTextAndEmpty: Bool {
        switch content {
        case .text(let textData):
            switch textData.contentType {
            case .code:
                return false
            default:
                return textData.attributedText.string.isEmpty
            }
        default:
            return false
        }
    }
}
