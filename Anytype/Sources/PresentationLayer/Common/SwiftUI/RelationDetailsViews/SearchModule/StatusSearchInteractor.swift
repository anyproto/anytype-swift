import Foundation

final class StatusSearchInteractor {
    
    private let viewModel: NewSearchViewModel<StatusSearchRow>
    private let allStatuses: [Relation.Status.Option]
    private let selectedStatus: Relation.Status.Option?
    
    init(viewModel: NewSearchViewModel<StatusSearchRow>, allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?) {
        self.viewModel = viewModel
        self.allStatuses = allStatuses
        self.selectedStatus = selectedStatus
    }
    
}

extension StatusSearchInteractor: NewSearchInteractorProtocol {
    
    func didAskToSearch(text: String) {
        guard text.isNotEmpty else {
            viewModel.update(rows: availableStatuses.asStatusSearchRows)
            return
        }

        let filteredStatuses: [Relation.Status.Option] = availableStatuses.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }

        viewModel.update(rows: filteredStatuses.asStatusSearchRows)
    }
    
    func didSelectRow(with rowId: UUID) {
        debugPrint(rowId)
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
