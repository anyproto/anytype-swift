import Foundation
import BlocksModels

final class RelationOptionsSearchViewModel: ObservableObject {
    
    @Published var selectedOptionIds: [String] = []
    @Published var searchResults: [RelationOptionsSearchData] = []
    
    private let type: RelationOptionsSearchType
    private let excludedIds: [String]
    private let addOptionsAction: ([String]) -> Void
    
    private let service = SearchService()
    
    init(
        type: RelationOptionsSearchType,
        excludedIds: [String],
        addOptionsAction: @escaping ([String]) -> Void
    ) {
        self.type = type
        self.excludedIds = excludedIds
        self.addOptionsAction = addOptionsAction
    }
    
}

extension RelationOptionsSearchViewModel {
    
    func search(text: String) {
        let result: [ObjectDetails]? = {
            let results: [ObjectDetails]?
            switch type {
            case .objects:
                results = service.search(text: text)
            case .files:
                results = service.searchFiles(text: text)
            }
            
            return results?.filter { !excludedIds.contains($0.id) }
        }()
        
        guard let result = result, result.isNotEmpty else {
            searchResults = []
            return
        }

        searchResults = result.map { RelationOptionsSearchData(details: $0) }
    }
    
    func didTapAddSelectedOptions() {
        addOptionsAction(selectedOptionIds)
    }
    
}
