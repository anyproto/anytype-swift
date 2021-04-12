import Foundation

public protocol RootIdProvider {
    var rootId: BlockId? {get set}
}

public protocol ContainerModel: class, RootIdProvider {
    var blocksContainer: BlockContainerModelProtocol {get set}
    var detailsContainer: DetailsContainerModelProtocol {get set}
}
