import Services
import Combine
import AnytypeCore

protocol BaseDocumentGeneralProtocol: AnyObject {
    var details: ObjectDetails? { get }
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> { get }
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { get }
    var syncPublisher: AnyPublisher<Void, Never> { get }
    var forPreview: Bool { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func openForPreview() async throws
    @MainActor
    func close() async throws
}

protocol BaseDocumentProtocol: AnyObject, BaseDocumentGeneralProtocol {
    var infoContainer: InfoContainerProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var detailsStorage: ObjectDetailsStorage { get }
    var objectId: BlockId { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var isLocked: Bool { get }
    var isEmpty: Bool { get }
    var isOpened: Bool { get }
    var isArchived: Bool { get }
    
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> { get }
    
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    func resetSubscriptions()
}
