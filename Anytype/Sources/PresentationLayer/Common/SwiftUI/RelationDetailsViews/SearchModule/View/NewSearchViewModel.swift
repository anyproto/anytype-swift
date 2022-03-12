import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    @Published private(set) var listModel: NewSearchView.ListModel = .plain(rows: [])
    
    private let internalViewModel: StatusSearchViewModel
    private var cancellable: AnyCancellable? = nil
    
    init(internalViewModel: StatusSearchViewModel) {
        self.internalViewModel = internalViewModel
        setupInternalViewModel()
    }
}

extension NewSearchViewModel {
    
    func didAskToSearch(text: String) {
        internalViewModel.search(text: text)
    }
    
    func didSelectRow(with id: String) {
        internalViewModel.handleRowSelect(rowId: id)
    }
    
}

private extension NewSearchViewModel {
    
    func setupInternalViewModel() {
        cancellable = internalViewModel.listModelPublisher.sink { [weak self] listModel in
            self?.listModel = listModel
        }
    }
    
}
