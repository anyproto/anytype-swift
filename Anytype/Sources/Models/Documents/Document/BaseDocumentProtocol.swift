import BlocksModels
import Combine

protocol BaseDocumentProtocol: AnyObject {
    var infoContainer: InfoContainerProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var relationsStorage: RelationsMetadataStorageProtocol { get }
    var objectId: BlockId { get }
    var updatePublisher: AnyPublisher<EventsListenerUpdate, Never> { get }
    var objectDetails: ObjectDetails? { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }

    @discardableResult
    func open() -> Bool
    func close()
}
