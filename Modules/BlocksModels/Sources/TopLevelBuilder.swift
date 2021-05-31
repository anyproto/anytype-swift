import Foundation

public enum TopLevelBuilder {
    public static let blockBuilder: BlockBuilderProtocol = BlockBuilder()
    
    public static func createRootContainer(
        rootId: BlockId?,
        blockContainer: BlockContainerModelProtocol,
        detailsContainer: DetailsContainerProtocol
    ) -> ContainerModelProtocol {
        RootBlocksContainer(
            rootId: rootId,
            blocksContainer: blockContainer,
            detailsContainer: detailsContainer
        )
    }
}
