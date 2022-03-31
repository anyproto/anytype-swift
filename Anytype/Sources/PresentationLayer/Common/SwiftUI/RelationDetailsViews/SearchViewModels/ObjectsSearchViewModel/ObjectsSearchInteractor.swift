import Foundation
import BlocksModels

final class ObjectsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let selectedObjectIds: [String]
    private let limitedObjectType: [String]
    
    init(searchService: SearchServiceProtocol, selectedObjectIds: [String], limitedObjectType: [String]) {
        self.searchService = searchService
        self.selectedObjectIds = selectedObjectIds
        self.limitedObjectType = limitedObjectType
    }
    
}

extension ObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ()) {
        let response = searchService.searchObjects(text: text, excludedObjectIds: [], limitedTypeUrls: limitedObjectType)
        let filteredResponse = response?.filter { !selectedObjectIds.contains($0.id) }
        
        onCompletion(filteredResponse ?? [])
    }
    
}
