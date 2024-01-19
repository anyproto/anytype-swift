import Combine
import Foundation

@MainActor
final class RelationContainerViewModel: ObservableObject {
    
    let title: String
    private weak var output: RelationContainerModuleOutput?
    
    init(title: String, output: RelationContainerModuleOutput?) {
        self.title = title
        self.output = output
    }

    func clearButtonTapped() {
        output?.clear()
    }
    
    func addButtonTapped() {
        output?.add()
    }
    
    func searchTextChanged(_ text: String) {
        output?.onSearch(text)
    }
}
