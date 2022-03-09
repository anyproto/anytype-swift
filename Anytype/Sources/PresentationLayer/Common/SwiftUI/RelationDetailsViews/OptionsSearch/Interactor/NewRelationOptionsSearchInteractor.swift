import Foundation
import BlocksModels

final class NewRelationOptionsSearchInteractor {

    private let type: RelationOptionsSearchType
    private let excludedOptionIds: [String]
    
    private let searchService: SearchServiceProtocol
    
    
    init(type: RelationOptionsSearchType, excludedOptionIds: [String], searchService: SearchServiceProtocol) {
        self.type = type
        self.excludedOptionIds = excludedOptionIds
        self.searchService = searchService
    }
    
}

extension NewRelationOptionsSearchInteractor: NewRelationOptionsSearchInteractorInput {
    
    func obtainOptions(for text: String, onCompletion: (RelationOptionsSearchResult?) -> Void) {
        let response: [ObjectDetails]? = {
            let results: [ObjectDetails]?
            switch type {
            case .objects:
                results = searchService.search(text: text)
            case .files:
                results = searchService.searchFiles(text: text)
            }
            
            return results?.filter { !excludedOptionIds.contains($0.id) }
        }()
        
        guard let response = response, response.isNotEmpty else {
            onCompletion(nil)
            return
        }
        

        let result: RelationOptionsSearchResult = {
            switch type {
            case .objects:
                return RelationOptionsSearchResult.objects(response)
            case .files:
                return RelationOptionsSearchResult.files(response)
            }
        }()

        onCompletion(result)
    }
    
}
