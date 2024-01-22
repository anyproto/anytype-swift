import Combine
import Foundation

@MainActor
final class StatusRelationListViewModel: ObservableObject {
    
    let title: String
    
    init(title: String) {
        self.title = title
    }

    func clear() {
    }
    
    func create() {
    }
    
    func searchTextChanged(_ text: String) {
    }
}
