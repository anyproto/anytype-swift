import Foundation

final class StatusSearchInteractor {
    
    private let allStatuses: [Relation.Status.Option]
    private let selectedStatus: Relation.Status.Option?
    
    init(allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?) {
        self.allStatuses = allStatuses
        self.selectedStatus = selectedStatus
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
        
        guard
            filteredStatuses.isEmpty,
            let selectedStatus = selectedStatus,
            selectedStatus.text.lowercased() == text.lowercased()
        else {
            return .success(filteredStatuses)
        }
        
        return .failure(
            NewSearchError(
                title: "\"\(text)\" \("is already selected".localized)",
                subtitle: nil
            )
        )
    }
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        searchText.isNotEmpty && !allStatuses.contains { $0.text.lowercased() == searchText.lowercased() }
    }
    
}

private extension StatusSearchInteractor {
    
    var availableStatuses: [Relation.Status.Option] {
        guard let selectedStatus = selectedStatus else {
            return allStatuses
        }
        
        return allStatuses.filter { $0.id != selectedStatus.id }
    }
    
}
