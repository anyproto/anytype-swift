import Foundation
import BlocksModels

final class RelationsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    func search(text: String, excludedIds: [String]) -> [RelationDetails] {
        return searchService.searchRelations(text: text, excludedIds: excludedIds) ?? []
    }
    
    func searchInMarketplace(text: String, excludedIds: [String]) -> [RelationDetails] {
        return searchService.searchMarketplaceRelations(text: text, excludedIds: excludedIds) ?? []
    }
    
    func installTypes(objectIds: [String]) -> [String] {
        return []
    }
}
