import Foundation

final class NewSearchViewModel: ObservableObject {
    
    @Published private(set) var rows: [StatusSearchRowViewModel] = []
    
    private let data: [Relation.Status.Option] = []
    
    private let interactor: NewSearchInteractorProtocol
    
    init(interactor: NewSearchInteractorProtocol) {
        self.interactor = interactor
    }
    
}

extension NewSearchViewModel {
    
    func didAskToSearch(text: String) {
        interactor.makeSearch(text: text) {
            // handle search results
        }
    }
    
    func didSelectRow(with rowId: Int) {
        
    }
    
}
