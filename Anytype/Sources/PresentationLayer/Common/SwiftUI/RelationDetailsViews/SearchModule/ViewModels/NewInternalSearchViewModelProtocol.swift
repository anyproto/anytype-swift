import Foundation
import Combine

protocol NewInternalSearchViewModelProtocol {
    
    var listModelPublisher: AnyPublisher<NewSearchView.ListModel, Never> { get }
    
    func search(text: String)
    
    func handleRowsSelect(rowIds: [String])
    
}
