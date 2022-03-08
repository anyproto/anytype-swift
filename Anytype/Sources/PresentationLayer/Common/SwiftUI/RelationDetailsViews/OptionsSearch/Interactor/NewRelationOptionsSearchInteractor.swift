import Foundation
import BlocksModels

final class NewRelationOptionsSearchInteractor {

    private let type: NewRelationOptionsSearchType
    private let excludedOptionIds: [String]
    
    private let searchService: SearchServiceProtocol
    
    init(type: NewRelationOptionsSearchType, excludedOptionIds: [String], searchService: SearchServiceProtocol) {
        self.type = type
        self.excludedOptionIds = excludedOptionIds
        self.searchService = searchService
    }
    
}

extension NewRelationOptionsSearchInteractor: NewRelationOptionsSearchInteractorInput {
    
    func obtainOptions(for text: String, onCompletion: (RelationOptionsSearchResult?) -> Void) {
        switch type {
        case .objects:
            onCompletion(searchObjects(with: text))
            return
        case .files:
            onCompletion(searchFiles(with: text))
            return
        case .tags(let allTags):
            onCompletion(searchTags(with: text, allTags: allTags))
            return
        case .statuses(let allStatuses):
            onCompletion(searchStatuses(with: text, allStatuses: allStatuses))
            return
        }
    }
    
}

private extension NewRelationOptionsSearchInteractor {
    
    func searchObjects(with text: String) -> RelationOptionsSearchResult? {
        let response = searchService.search(text: text)
        let filteredResponse = response?.filter { !excludedOptionIds.contains($0.id) }
        
        guard let response = filteredResponse, response.isNotEmpty else {
            return nil
        }
        
        return RelationOptionsSearchResult.objects(response)
    }
    
    func searchFiles(with text: String) -> RelationOptionsSearchResult? {
        let response = searchService.searchFiles(text: text)
        let filteredResponse = response?.filter { !excludedOptionIds.contains($0.id) }
        
        guard let response = filteredResponse, response.isNotEmpty else {
            return nil
        }
        
        return RelationOptionsSearchResult.files(response)
    }
    
    func searchTags(with text: String, allTags: [Relation.Tag.Option]) -> RelationOptionsSearchResult? {
        guard text.isNotEmpty else {
            return RelationOptionsSearchResult.tags(allTags)
        }
        
        let availableTags = allTags.filter { !excludedOptionIds.contains($0.id) }
        let filteredTags: [Relation.Tag.Option] = availableTags.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }

        guard filteredTags.isNotEmpty else {
            return nil
        }
        
        return RelationOptionsSearchResult.tags(filteredTags)
    }
    
    func searchStatuses(with text: String, allStatuses: [Relation.Status.Option]) -> RelationOptionsSearchResult? {
        guard text.isNotEmpty else {
            return RelationOptionsSearchResult.statuses(allStatuses)
        }
        
        let availableStatuses = allStatuses.filter { !excludedOptionIds.contains($0.id) }
        let filteredStatuses: [Relation.Status.Option] = availableStatuses.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }

        guard filteredStatuses.isNotEmpty else {
            return nil
        }
        
        return RelationOptionsSearchResult.statuses(filteredStatuses)
    }
    
}
