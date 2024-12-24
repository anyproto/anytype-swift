import Foundation
import Combine

@MainActor
protocol NewInternalSearchViewModelProtocol {
    
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { get }
    
    var selectionMode: LegacySearchViewModel.SelectionMode { get }
    
    func search(text: String) async throws
    
    func handleRowsSelection(ids: [String])
    
    func createButtonModel(searchText: String) -> LegacySearchViewModel.CreateButtonModel
    
    func handleConfirmSelection(ids: [String])
}

extension NewInternalSearchViewModelProtocol {
    
    func createButtonModel(searchText: String) -> LegacySearchViewModel.CreateButtonModel {
        return .disabled
    }
    
}
