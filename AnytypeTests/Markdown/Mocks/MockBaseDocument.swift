import Foundation
import Combine
import Services
import AnytypeCore
@testable import Anytype

class MockBaseDocument: BaseDocumentProtocol, @unchecked Sendable {
    // Configurable properties
    var mockInfoContainer: any InfoContainerProtocol = InfoContainerMock()
    var mockDetailsStorage = ObjectDetailsStorage()
    var mockChildren: [BlockInformation] = []
    var mockParsedProperties = ParsedProperties.empty
    var mockObjectId: String
    var mockSpaceId: String = "test-space-id"
    var mockIsLocked: Bool = false
    var mockIsEmpty: Bool = false
    var mockIsOpened: Bool = true
    var mockMode: DocumentMode = .handling
    var mockDetails: ObjectDetails?
    var mockPermissions: ObjectPermissions = ObjectPermissions()
    var mockSyncStatus: SpaceSyncStatus?
    
    // Publishers
    private let updateSubject = PassthroughSubject<[BaseDocumentUpdate], Never>()
    
    // Configurable closures for async methods
    var openHandler: (() async throws -> Void)?
    var updateHandler: (() async throws -> Void)?
    var closeHandler: (() async throws -> Void)?
    
    init(objectId: String = UUID().uuidString, details: ObjectDetails? = nil) {
        self.mockObjectId = objectId
        self.mockDetails = details
    }
    
    // Protocol conformance
    var infoContainer: any InfoContainerProtocol { mockInfoContainer }
    var detailsStorage: ObjectDetailsStorage { mockDetailsStorage }
    var children: [BlockInformation] { mockChildren }
    var parsedProperties: ParsedProperties { mockParsedProperties }
    
    var objectId: String { mockObjectId }
    var spaceId: String { mockSpaceId }
    var isLocked: Bool { mockIsLocked }
    var isEmpty: Bool { mockIsEmpty }
    var isOpened: Bool { mockIsOpened }
    var mode: DocumentMode { mockMode }
    var details: ObjectDetails? { mockDetails }
    var permissions: ObjectPermissions { mockPermissions }
    var syncStatus: SpaceSyncStatus? { mockSyncStatus }
    
    var syncPublisher: AnyPublisher<[BaseDocumentUpdate], Never> {
        updateSubject.eraseToAnyPublisher()
    }
    
    func subscibeFor(update: [BaseDocumentUpdate]) -> AnyPublisher<[BaseDocumentUpdate], Never> {
        updateSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    func open() async throws {
        try await openHandler?()
    }
    
    @MainActor
    func update() async throws {
        try await updateHandler?()
    }
    
    @MainActor
    func close() async throws {
        try await closeHandler?()
    }
    
    // Helper method to simulate updates
    func simulateUpdate(_ updates: [BaseDocumentUpdate]) {
        updateSubject.send(updates)
    }
}

// Extension to make mocking easier in tests
extension MockBaseDocument {
    convenience init(
        objectId: String = UUID().uuidString,
        recommendedFeaturedRelations: [String] = [],
        recommendedRelations: [String] = []
    ) {
        var mockDetails = ObjectDetails.init(
            id: objectId,
            values: [
                BundledPropertyKey.recommendedRelations.rawValue: recommendedRelations.protobufValue,
                BundledPropertyKey.recommendedFeaturedRelations.rawValue: recommendedFeaturedRelations.protobufValue
            ]
        )
        
        self.init(objectId: objectId, details: mockDetails)
    }
}
