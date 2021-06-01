import Foundation
import Combine

public protocol BlockModelProtocol: BlockHasDidChangePublisherProtocol {
    
    var information: BlockInformation { get set }
    init(information: BlockInformation)
    
    var parent: BlockId? {get set}
    var kind: BlockKind {get}
}
