import Foundation


/// The main intention of this class is to store rootId and store all containers together.
/// As soon as we don't use rootId in `Block.Container`, it is safe to transfer it here.
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
