import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    @Published private(set) var rows: [NewSearchRowConfiguration] = []
    
    private let internalViewModel: StatusSearchViewModel
    private var cancellable: AnyCancellable? = nil
    
    init(internalViewModel: StatusSearchViewModel) {
        self.internalViewModel = internalViewModel
        self.cancellable = internalViewModel.$rows.sink { [weak self] rows in
            self?.rows = rows
        }
    }
}

extension NewSearchViewModel {
    
    func didAskToSearch(text: String) {
        internalViewModel.didAskToSearch(text: text)
    }
    
    func didSelectRow(with id: String) {
        internalViewModel.didSelectRow(with: id)
    }
    
}
