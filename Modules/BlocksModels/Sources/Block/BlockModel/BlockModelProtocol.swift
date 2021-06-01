import Foundation
import Combine

public protocol BlockModelProtocol: BlockHasDidChangePublisherProtocol {
    
    var information: BlockInformation.InformationModel { get set }
    init(information: BlockInformation.InformationModel)
    
    var parent: BlockId? {get set}
    var kind: BlockKind {get}
}
