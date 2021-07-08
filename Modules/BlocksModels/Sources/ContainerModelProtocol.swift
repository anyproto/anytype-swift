import Foundation

public protocol ContainerModelProtocol: AnyObject {
    var rootId: BlockId? { get }
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsContainer: DetailsContainerProtocol { get }
}
