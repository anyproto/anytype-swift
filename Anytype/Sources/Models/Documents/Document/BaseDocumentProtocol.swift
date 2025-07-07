import Services
import Combine
import AnytypeCore

protocol BaseDocumentProtocol: AnyObject, Sendable {
    var infoContainer: any InfoContainerProtocol { get }
    var detailsStorage: ObjectDetailsStorage { get }
    var children: [BlockInformation] { get }
    var parsedProperties: ParsedProperties { get }
    var objectId: String { get }
    var spaceId: String { get }
    var isLocked: Bool { get }
    var isEmpty: Bool { get }
    var isOpened: Bool { get }
    var mode: DocumentMode { get }
    var details: ObjectDetails? { get }
    var permissions: ObjectPermissions { get }
    var syncStatus: SpaceSyncStatus? { get }
    
    func subscibeFor(update: [BaseDocumentUpdate]) -> AnyPublisher<[BaseDocumentUpdate], Never>
    var syncPublisher: AnyPublisher<[BaseDocumentUpdate], Never> { get }
    
    @MainActor
    func open() async throws
    
    @MainActor
    func update() async throws
    
    @MainActor
    func close() async throws
}
