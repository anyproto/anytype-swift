import BlocksModels
import Combine
import AnytypeCore

protocol BaseDocumentProtocol: AnyObject {
    var infoContainer: InfoContainerProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var relationsStorage: RelationsMetadataStorageProtocol { get }
    var objectId: AnytypeId { get }
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { get }
    var details: ObjectDetails? { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var isLocked: Bool { get }

    @discardableResult
    func open() -> Bool

    @discardableResult
    func openForPreview() -> Bool
    func close()
}
