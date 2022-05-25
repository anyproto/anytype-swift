import Foundation
import BlocksModels

final class MoveToSearchInteractor {
    
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

extension MoveToSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) -> [ObjectDetails] {
        let response = searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            excludedTypeUrls: [
                ObjectTemplateType.BundledType.set.rawValue
            ],
            sortRelationKey: .lastModifiedDate
        )
        return response ?? []
    }
}
