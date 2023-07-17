import Foundation
import Combine

protocol NewInternalSearchViewModelProtocol {
    
    var viewStateSubject: PassthroughSubject<NewSearchViewState, Never> { get }
    
    var selectionMode: NewSearchViewModel.SelectionMode { get }
    
    func search(text: String) async throws
    
    func handleRowsSelection(ids: [String])
    
    func createButtonModel(searchText: String) -> NewSearchViewModel.CreateButtonModel
    
    func handleConfirmSelection(ids: [String])
}

extension NewInternalSearchViewModelProtocol {
    
    func createButtonModel(searchText: String) -> NewSearchViewModel.CreateButtonModel {
        return .disabled
    }
    
}
