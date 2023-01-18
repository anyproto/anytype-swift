import Foundation
import BlocksModels

final class BlockObjectsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectIds: [String]
                
    init(
        searchService: SearchServiceProtocol,
        excludedObjectIds: [String]
    ) {
        self.searchService = searchService
        self.excludedObjectIds = excludedObjectIds
    }
}

extension BlockObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) -> [ObjectDetails] {
        let response = searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            excludedTypeIds: [
                ObjectTypeId.bundled(.set).rawValue
            ],
            sortRelationKey: .lastModifiedDate
        )
        return response ?? []
    }
}
