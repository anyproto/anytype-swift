import Foundation
import BlocksModels

final class ObjectTypesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectTypeId: String?
    
    init(searchService: SearchServiceProtocol, excludedObjectTypeId: String?) {
        self.searchService = searchService
        self.excludedObjectTypeId = excludedObjectTypeId
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ()) {
        let response = searchService.searchObjectTypes(
            text: text,
            filteringTypeUrl: excludedObjectTypeId
        )
        onCompletion(response ?? [])
    }
    
}

