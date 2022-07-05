import Foundation

final class StatusSearchInteractor {
    
    private let allStatuses: [Relation.Status.Option]
    private let selectedStatuses: [Relation.Status.Option]
    
    init(allStatuses: [Relation.Status.Option], selectedStatuses: [Relation.Status.Option]) {
        self.allStatuses = allStatuses
        self.selectedStatuses = selectedStatuses
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
                selectedStatuses.contains { $0.id == status.id }
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
        guard selectedStatuses.isNotEmpty else { return allStatuses }
        
        return allStatuses.filter { status in
            !selectedStatuses.contains { $0.id == status.id }
        }
    }
    
}
