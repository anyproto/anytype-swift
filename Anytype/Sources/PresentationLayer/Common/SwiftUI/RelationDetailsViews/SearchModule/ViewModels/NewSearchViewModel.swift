import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    @Published private(set) var rows: [NewSearchRowConfiguration] = []
    
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
        cancellable = internalViewModel.rowsPublisher.sink { [weak self] rows in
            self?.rows = rows
        }
    }
    
}
