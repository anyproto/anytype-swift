import Foundation

final class StatusSearchInteractor {
    
    private let allStatuses: [Relation.Status.Option]
    private let selectedStatusesIds: [String]
    private let isPreselectModeAvailable: Bool
    
    init(
        allStatuses: [Relation.Status.Option],
        selectedStatusesIds: [String],
        isPreselectModeAvailable: Bool
    ) {
        self.allStatuses = allStatuses
        self.selectedStatusesIds = selectedStatusesIds
        self.isPreselectModeAvailable = isPreselectModeAvailable
    }
    
}

extension StatusSearchInteractor {
    
    func search(text: String) -> Result<[Relation.Status.Option], NewSearchError> {
        guard text.isNotEmpty else {
            return .success(availableStatuses)
        }

        let filteredStatuses: [Relation.Status.Option] = availableStatuses.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }
        
        if filteredStatuses.isEmpty {
            let isSearchedStatusSelected = allStatuses.filter { status in
                selectedStatusesIds.contains { $0 == status.id }
            }.contains { $0.text.lowercased() == text.lowercased() }
            return isSearchedStatusSelected ?
                .failure(.alreadySelected(searchText: text)) :
                .success(filteredStatuses)
        } else {
            return .success(filteredStatuses)
        }
    }
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        searchText.isNotEmpty && !allStatuses.contains { $0.text.lowercased() == searchText.lowercased() }
    }
    
}

private extension StatusSearchInteractor {
    
    var availableStatuses: [Relation.Status.Option] {
        guard selectedStatusesIds.isNotEmpty, !isPreselectModeAvailable else { return allStatuses }
        
        return allStatuses.filter { status in
            !selectedStatusesIds.contains { $0 == status.id }
        }
    }
    
}
