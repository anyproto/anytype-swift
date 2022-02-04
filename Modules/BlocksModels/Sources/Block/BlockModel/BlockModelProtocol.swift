import Foundation
import Combine
import SwiftProtobuf

public protocol BlockModelProtocol {
    var information: BlockInformation { get set }
    init(information: BlockInformation)

    var parent: BlockModelProtocol? { get set }
    var kind: BlockKind { get }

    var indentationLevel: Int { get set }
    var isToggled: Bool { get }

    func toggle()
}

public extension BlockInformation {
    var isTextAndEmpty: Bool {
        switch content {
        case .text(let textData):
            switch textData.contentType {
            case .code:
                return false
            default:
                return textData.text.isEmpty
            }
        default:
            return false
        }
    }
}
