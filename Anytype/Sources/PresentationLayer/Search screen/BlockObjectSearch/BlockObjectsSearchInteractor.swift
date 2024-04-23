import Foundation
import Services

final class BlockObjectsSearchInteractor {
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
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
