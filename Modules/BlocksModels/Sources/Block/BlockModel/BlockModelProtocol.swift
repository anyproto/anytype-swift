import Foundation
import Combine

public protocol BlockModelProtocol: BlockHasDidChangePublisherProtocol {
    
    var information: BlockInformation { get set }
    init(information: BlockInformation)
    
    var parent: BlockId? {get set}
    var kind: BlockKind {get}
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
