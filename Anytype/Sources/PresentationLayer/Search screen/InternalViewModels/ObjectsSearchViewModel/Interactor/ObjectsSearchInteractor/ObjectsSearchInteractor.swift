import Foundation
import Services

final class ObjectsSearchInteractor {
    
    private let spaceId: String
    private let excludedObjectIds: [String]
    private let limitedObjectType: [String]
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    init(spaceId: String, excludedObjectIds: [String], limitedObjectType: [String]) {
        self.spaceId = spaceId
        self.excludedObjectIds = excludedObjectIds
        self.limitedObjectType = limitedObjectType
    }
    
}

extension ObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjectsByTypes(
            text: text,
            typeIds: limitedObjectType,
            excludedObjectIds: excludedObjectIds,
            spaceId: spaceId
        )
    }
    
}
