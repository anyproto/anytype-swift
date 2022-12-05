import Foundation
import BlocksModels

final class StatusSearchInteractor {
    
    private let relationKey: String
    private let selectedStatusesIds: [String]
    private let isPreselectModeAvailable: Bool
    private let searchService = ServiceLocator.shared.searchService()
    
    init(
        relationKey: String,
        selectedStatusesIds: [String],
        isPreselectModeAvailable: Bool
    ) {
        self.relationKey = relationKey
        self.selectedStatusesIds = selectedStatusesIds
        self.isPreselectModeAvailable = isPreselectModeAvailable
    }
    
}

extension StatusSearchInteractor {
    
    func search(text: String) -> Result<[Relation.Status.Option], NewSearchError> {
        let statuses = searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedStatusesIds)?
            .map { Relation.Status.Option(option: $0) } ?? []
        
        return .success(statuses)
    }
    
    func isCreateButtonAvailable(searchText: String, statuses: [Relation.Status.Option]) -> Bool {
        searchText.isNotEmpty && statuses.isEmpty
    }
    
}
