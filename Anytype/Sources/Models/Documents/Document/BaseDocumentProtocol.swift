import BlocksModels
import Combine

protocol BaseDocumentProtocol: AnyObject {
    var blocksContainer: BlockContainerModelProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var relationsStorage: RelationsMetadataStorageProtocol { get }
    var objectId: BlockId { get }
    var updatePublisher: AnyPublisher<EventsListenerUpdate, Never> { get }
    var objectDetails: ObjectDetails? { get }
    var flattenBlocks: [BlockModelProtocol] { get }
    var parsedRelations: ParsedRelations { get }

    @discardableResult
    func open() -> Bool
    func close()
}
