import Foundation


/// The main intention of this class is to store rootId and store all containers together.
/// As soon as we don't use rootId in `Block.Container`, it is safe to transfer it here.
final class RootBlocksContainer: ContainerModelProtocol {
    
    let rootId: BlockId?
    let blocksContainer: BlockContainerModelProtocol
    let detailsContainer: DetailsContainerProtocol
    
    init(rootId: BlockId?,
         blocksContainer: BlockContainerModelProtocol,
         detailsContainer: DetailsContainerProtocol
    ) {
        self.rootId = rootId
        self.blocksContainer = blocksContainer
        self.detailsContainer = detailsContainer
    }
    
}
