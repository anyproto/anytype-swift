import Foundation
import Services

@MainActor
final class BlockObjectsSearchInteractor {
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var objectCreationService: any DefaultObjectCreationServiceProtocol
    
    private let spaceId: String
    private let excludedObjectIds: [String]
    private let excludedLayouts: [DetailsLayout]
    
    init(
        spaceId: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout]
    ) {
        self.spaceId = spaceId
        self.excludedObjectIds = excludedObjectIds
        self.excludedLayouts = excludedLayouts
    }
    
    func createObject(name: String) async throws -> ObjectDetails {
        try await objectCreationService.createDefaultObject(name: name, shouldDeleteEmptyObject: false, spaceId: spaceId)
    }
}

extension BlockObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            excludedLayouts: excludedLayouts + [.participant],
            spaceId: spaceId,
            sortRelationKey: .lastModifiedDate
        )
    }
}
