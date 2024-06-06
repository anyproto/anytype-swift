import Services
import Combine
import AnytypeCore

protocol BaseDocumentProtocol: AnyObject {
    var infoContainer: InfoContainerProtocol { get }
    var detailsStorage: ObjectDetailsStorage { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var syncStatus: SyncStatus { get }
    var objectId: String { get }
    var spaceId: String { get }
    var isLocked: Bool { get }
    var isEmpty: Bool { get }
    var isOpened: Bool { get }
    var forPreview: Bool { get }
    
    var details: ObjectDetails? { get }
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> { get }
    
    var permissions: ObjectPermissions { get }
    var permissionsPublisher: AnyPublisher<ObjectPermissions, Never> { get }
    
    func subscibeFor(update: [BaseDocumentUpdate]) -> AnyPublisher<[BaseDocumentUpdate], Never>
    var syncDocPublisher: AnyPublisher<[BaseDocumentUpdate], Never> { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func openForPreview() async throws
    @MainActor
    func close() async throws
}
