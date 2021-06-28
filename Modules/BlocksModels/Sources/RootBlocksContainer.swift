import Foundation

public final class RootBlocksContainer: ContainerModelProtocol {
    
    public let rootId: BlockId?
    public let blocksContainer: BlockContainerModelProtocol
    public let detailsContainer: DetailsContainerProtocol
    
    public init(
        rootId: BlockId?,
        blocksContainer: BlockContainerModelProtocol,
        detailsContainer: DetailsContainerProtocol
    ) {
        self.rootId = rootId
        self.blocksContainer = blocksContainer
        self.detailsContainer = detailsContainer
    }
}
