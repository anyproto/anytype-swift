import Foundation

public final class RootBlockContainer {
    
    public let rootId: BlockId
    public let blocksContainer: BlockContainerModelProtocol
    
    public let detailsStorage: ObjectDetailsStorageProtocol
    
    public init(
        rootId: BlockId,
        blocksContainer: BlockContainerModelProtocol,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        self.rootId = rootId
        self.blocksContainer = blocksContainer
        self.detailsStorage = detailsStorage
    }
}
