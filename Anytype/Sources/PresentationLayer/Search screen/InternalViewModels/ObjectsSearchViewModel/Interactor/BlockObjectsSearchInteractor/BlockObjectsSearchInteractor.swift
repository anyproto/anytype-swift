import Foundation
import Services

final class BlockObjectsSearchInteractor {
    
    private let spaceId: String
    private let excludedObjectIds: [String]
    private let excludedLayouts: [DetailsLayout]
    private let searchService: SearchServiceProtocol
    
    init(
        spaceId: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout],
        searchService: SearchServiceProtocol
    ) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.excludedObjectIds = excludedObjectIds
        self.excludedLayouts = excludedLayouts
    }
}

extension BlockObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            excludedLayouts: excludedLayouts,
            spaceId: spaceId,
            sortRelationKey: .lastModifiedDate
        )
    }
}
