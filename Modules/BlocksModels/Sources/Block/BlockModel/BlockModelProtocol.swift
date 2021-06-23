import Foundation
import Combine

public protocol BlockModelProtocol: BlockHasDidChangePublisherProtocol {
    
    var information: BlockInformation { get set }
    init(information: BlockInformation)
    
    var parent: BlockId? {get set}
    var kind: BlockKind {get}
}

public extension BlockModelProtocol {
    var isTextAndEmpty: Bool {
        switch information.content {
        case .text(let textData):
            return textData.attributedText.string.isEmpty
        default:
            return false
        }
    }
}
