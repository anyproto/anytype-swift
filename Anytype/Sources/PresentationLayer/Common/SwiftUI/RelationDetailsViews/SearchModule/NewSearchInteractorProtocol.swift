import Foundation

protocol NewSearchInteractorProtocol {

    func didAskToSearch(text: String)
    func didSelectRow(with rowId: UUID)
    
}
