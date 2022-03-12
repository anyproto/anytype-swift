import Foundation

protocol NewInternalSearchViewModelProtocol {
    
    var rowsPublisher: Published<[NewSearchRowConfiguration]>.Publisher { get }
    
    func search(text: String)
    func handleRowSelect(rowId: String)
    
}
