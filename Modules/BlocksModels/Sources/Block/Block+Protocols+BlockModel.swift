import Foundation
import Combine

// MARK: - BlockModel
public protocol BlockHasInformationProtocol {
    var information: BlockInformation.InformationModel { get set }
    init(information: BlockInformation.InformationModel)
}

public protocol BlockHasParentProtocol {
    var parent: BlockId? {get set}
}

public protocol BlockHasKindProtocol {
    var kind: BlockKind {get}
}
