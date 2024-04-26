import Services
import Combine
import AnytypeCore

protocol BaseDocumentGeneralProtocol: AnyObject {
    var syncStatus: AnyPublisher<SyncStatus, Never> { get }
    
    var objectId: String { get }
    var spaceId: String { get }
    var details: ObjectDetails? { get }
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> { get }
    var syncPublisher: AnyPublisher<Void, Never> { get }
    var forPreview: Bool { get }
    var permissions: ObjectPermissions { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func openForPreview() async throws
    @MainActor
    func close() async throws
}

protocol BaseDocumentProtocol: AnyObject, BaseDocumentGeneralProtocol {
    var infoContainer: InfoContainerProtocol { get }
    var detailsStorage: ObjectDetailsStorage { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var isLocked: Bool { get }
    var isEmpty: Bool { get }
    var isOpened: Bool { get }
    
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> { get }
    var childrenPublisher: AnyPublisher<[BlockInformation], Never> { get }
    var syncPublisher: AnyPublisher<Void, Never> { get }
    var resetBlocksSubject: PassthroughSubject<Set<String>, Never> { get }
    var permissionsPublisher: AnyPublisher<ObjectPermissions, Never> { get }
}
