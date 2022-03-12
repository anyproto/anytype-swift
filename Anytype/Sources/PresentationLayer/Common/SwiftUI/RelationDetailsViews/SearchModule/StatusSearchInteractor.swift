import Foundation

final class StatusSearchInteractor {
    
    private let allStatuses: [Relation.Status.Option]
    private let selectedStatus: Relation.Status.Option?
    
    init(allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?) {
        self.allStatuses = allStatuses
        self.selectedStatus = selectedStatus
    }
    
}

extension StatusSearchInteractor: NewSearchInteractorProtocol {
    
    func makeSearch(text: String, onCompletion: () -> ()) {
        guard text.isNotEmpty else {
            onCompletion()
//            viewModel.update(rows: availableStatuses.asStatusSearchRows)
            return
        }

        let filteredStatuses: [Relation.Status.Option] = availableStatuses.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }
        onCompletion()
//        viewModel.update(rows: filteredStatuses.asStatusSearchRows)
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

private extension StatusSearchRowViewModel {
    
    init(status: Relation.Status.Option) {
        self.text = status.text
        self.color = status.color
    }
    
}

private extension Array where Element == Relation.Status.Option {
    
    var asStatusSearchRows: [StatusSearchRow] {
        self.map {
            StatusSearchRow(
                viewModel: StatusSearchRowViewModel(status: $0)
            )
        }
    }
}
