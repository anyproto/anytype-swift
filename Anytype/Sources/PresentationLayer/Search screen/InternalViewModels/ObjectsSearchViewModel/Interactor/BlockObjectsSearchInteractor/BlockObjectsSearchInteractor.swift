import Foundation
import Services

final class BlockObjectsSearchInteractor {
    
    private let spaceId: String
    private let excludedObjectIds: [String]
    private let excludedTypeIds: [String]
    private let searchService: SearchServiceProtocol
    
    init(
        spaceId: String,
        excludedObjectIds: [String],
        excludedTypeIds: [String],
        searchService: SearchServiceProtocol
    ) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.excludedObjectIds = excludedObjectIds
        self.excludedTypeIds = excludedTypeIds
    }
}

extension BlockObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            excludedTypeIds: excludedTypeIds,
            spaceId: spaceId,
            sortRelationKey: .lastModifiedDate
        )
    }
}
