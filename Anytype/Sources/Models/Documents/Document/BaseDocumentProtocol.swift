import BlocksModels
import Combine
import AnytypeCore

protocol BaseDocumentProtocol: AnyObject {
    var infoContainer: InfoContainerProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var relationsStorage: RelationsMetadataStorageProtocol { get }
    var objectId: BlockId { get }
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { get }
    var details: ObjectDetails? { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var isLocked: Bool { get }
    var isOpened: Bool { get }

    func open(completion: @escaping (Bool) -> Void)
    func openForPreview(completion: @escaping (Bool) -> Void)
    func close(completion: @escaping (Bool) -> Void)
}
