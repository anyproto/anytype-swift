import Foundation
import Combine

protocol NewInternalSearchViewModelProtocol {
    
    var viewStateSubject: PassthroughSubject<NewSearchViewState, Never> { get }
    
    var selectionMode: NewSearchViewModel.SelectionMode { get }
    
    func search(text: String)
    
    func handleRowsSelection(ids: [String])
    
    func isCreateButtonAvailable(searchText: String) -> Bool
    
}

extension NewInternalSearchViewModelProtocol {
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        searchText.isNotEmpty
    }
    
}
