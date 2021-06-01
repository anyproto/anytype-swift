import Foundation
import Combine

public protocol BlockModelProtocol: BlockHasDidChangePublisherProtocol {
    
    var information: BlockInformationModel { get set }
    init(information: BlockInformationModel)
    
    var parent: BlockId? {get set}
    var kind: BlockKind {get}
}
