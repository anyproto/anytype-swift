import Foundation

public protocol TopLevelBuilder {
    static var blockBuilder: BlockBuilderProtocol {get}
    static var detailsBuilder: DetailsBuilderProtocol {get}
    static func emptyContainer() -> ContainerModel
    static func createRootContainer(rootId: String?, blockContainer: BlockContainerModelProtocol, detailsContainer: DetailsContainerModelProtocol) -> ContainerModel
}


public enum TopLevelBuilderImpl: TopLevelBuilder {
    public static var blockBuilder: BlockBuilderProtocol = Block.Builder.init()
    public static var detailsBuilder: DetailsBuilderProtocol = Details.Builder.init()
    
    public static func emptyContainer() -> ContainerModel {
        RootBlocksContainer()
    }
    
    public static func createRootContainer(rootId: BlockId?,
                             blockContainer: BlockContainerModelProtocol,
                             detailsContainer: DetailsContainerModelProtocol) -> ContainerModel {
        let container = RootBlocksContainer()
        container.rootId = rootId
        container.blocksContainer = blockContainer
        container.detailsContainer = detailsContainer
        return container
    }
}
