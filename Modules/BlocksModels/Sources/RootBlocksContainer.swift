import Foundation

public final class RootBlockContainer {
    
    public let blocksContainer: BlockContainerModelProtocol
    
    public let detailsStorage: ObjectDetailsStorageProtocol
    
    public init(
        blocksContainer: BlockContainerModelProtocol,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        self.blocksContainer = blocksContainer
        self.detailsStorage = detailsStorage
    }
}
