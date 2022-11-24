import BlocksModels
import Combine
import AnytypeCore

protocol BaseDocumentProtocol: AnyObject {
    var infoContainer: InfoContainerProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var objectId: BlockId { get }
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { get }
    var details: ObjectDetails? { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var isLocked: Bool { get }
    var isEmpty: Bool { get }
    var isOpened: Bool { get }
    
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> { get }
    var isLockedPublisher: AnyPublisher<Bool, Never> { get }
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func openForPreview() async throws
    @MainActor
    func close() async throws
}
