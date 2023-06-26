import Foundation
import Services

final class BlockObjectsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectIds: [String]
    private let excludedTypeIds: [String]
                
    init(
        searchService: SearchServiceProtocol,
        excludedObjectIds: [String],
        excludedTypeIds: [String]
    ) {
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
            sortRelationKey: .lastModifiedDate
        )
    }
}
