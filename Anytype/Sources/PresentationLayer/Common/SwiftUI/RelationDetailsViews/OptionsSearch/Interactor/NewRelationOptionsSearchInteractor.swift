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
    
    func obtainOptions(for text: String, onCompletion: ([RelationOptionSearchItem]) -> Void) {
        let result: [ObjectDetails]? = {
            let results: [ObjectDetails]?
            switch type {
            case .objects:
                results = searchService.search(text: text)
            case .files:
                results = searchService.searchFiles(text: text)
            }
            
            return results?.filter { !excludedOptionIds.contains($0.id) }
        }()
        
        guard let result = result, result.isNotEmpty else {
            onCompletion([])
            return
        }

        let items: [RelationOptionSearchItem] = {
            result.map {
                switch type {
                case .objects:
                    return RelationOptionSearchItem.object($0)
                case .files:
                    return RelationOptionSearchItem.file($0)
                }
            }
        }()
        
        onCompletion(items)
    }
    
}
