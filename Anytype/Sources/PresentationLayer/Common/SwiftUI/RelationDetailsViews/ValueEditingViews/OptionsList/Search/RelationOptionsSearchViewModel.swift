import Foundation
import BlocksModels

final class RelationOptionsSearchViewModel: ObservableObject {
    
    @Published var selectedOptionIds: [String] = []
    @Published var options: [RelationOptionsSearchData] = []
    
    private let excludeOptionIds: [String]
    private let searchAction: (SearchServiceProtocol, String) -> [ObjectDetails]?
    private let addOptionsAction: ([String]) -> Void
    private let service = SearchService()
    
    init(
        excludeOptionIds: [String],
        searchAction: @escaping (SearchServiceProtocol, String) -> [ObjectDetails]?,
        addOptionsAction: @escaping ([String]) -> Void
    ) {
        self.excludeOptionIds = excludeOptionIds
        self.searchAction = searchAction
        self.addOptionsAction = addOptionsAction
    }
    
}

extension RelationOptionsSearchViewModel {
    
    func search(text: String) {
        let result: [ObjectDetails]? = searchAction(service, text)?.filter { !excludeOptionIds.contains($0.id) }
        
        guard let result = result, result.isNotEmpty else {
            options = []
            return
        }

        options = result.map { RelationOptionsSearchData(details: $0) }
    }
    
    func didTapOnOption(_ object: RelationOptionsSearchData) {
        let id = object.id
        if selectedOptionIds.contains(id) {
            selectedOptionIds = selectedOptionIds.filter { $0 != id }
        } else {
            selectedOptionIds.append(id)
        }
    }
    
    func didTapAddSelectedOptions() {
        addOptionsAction(selectedOptionIds)
    }
    
}
