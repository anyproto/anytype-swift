import Foundation
import BlocksModels

final class ObjectsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectIds: [String]
    private let limitedObjectType: [String]
    
    init(searchService: SearchServiceProtocol, excludedObjectIds: [String], limitedObjectType: [String]) {
        self.searchService = searchService
        self.excludedObjectIds = excludedObjectIds
        self.limitedObjectType = limitedObjectType
    }
    
}

extension ObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ()) {
        let response = searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            limitedTypeUrls: limitedObjectType
        )
        onCompletion(response ?? [])
    }
    
}
