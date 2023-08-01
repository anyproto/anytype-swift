import Foundation
import Services

final class ObjectsSearchInteractor {
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    private let excludedObjectIds: [String]
    private let limitedObjectType: [String]
    
    init(spaceId: String, searchService: SearchServiceProtocol, excludedObjectIds: [String], limitedObjectType: [String]) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.excludedObjectIds = excludedObjectIds
        self.limitedObjectType = limitedObjectType
    }
    
}

extension ObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            limitedTypeIds: limitedObjectType,
            spaceId: spaceId
        )
    }
    
}
