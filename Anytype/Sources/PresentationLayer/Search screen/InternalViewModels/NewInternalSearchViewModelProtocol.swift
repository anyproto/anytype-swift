import Foundation
import Combine

protocol NewInternalSearchViewModelProtocol {
    
    var viewStateSubject: PassthroughSubject<NewSearchViewState, Never> { get }
    
    var selectionMode: NewSearchViewModel.SelectionMode { get }
    
    func search(text: String)
    
    func handleRowsSelection(ids: [String])
    
    func createButtonModel(searchText: String) -> NewSearchCreateButtonModel
    
    func handleConfirmSelection(ids: [String])
}

extension NewInternalSearchViewModelProtocol {
    
    func createButtonModel(searchText: String) -> NewSearchCreateButtonModel {
        return NewSearchCreateButtonModel(show: false)
    }
    
}
