import Foundation

public protocol RootIdProvider {
    var rootId: BlockId? {get set}
}

public protocol ContainerModel: AnyObject, RootIdProvider {
    var blocksContainer: BlockContainerModelProtocol { get set }
    var detailsStorage: DetailsStorageProtocol { get set }
}
