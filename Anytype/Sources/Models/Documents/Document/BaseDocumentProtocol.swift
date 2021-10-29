import BlocksModels
import Combine

protocol BaseDocumentProtocol: AnyObject {
    var blocksContainer: BlockContainerModelProtocol { get }
    var detailsStorage: ObjectDetailsStorageProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var objectId: BlockId { get }
    var updatePublisher: AnyPublisher<EventsListenerUpdate, Never> { get }
    var objectDetails: ObjectDetails? { get }
    var flattenBlocks: [BlockModelProtocol] { get }

    func open() -> Bool
}
