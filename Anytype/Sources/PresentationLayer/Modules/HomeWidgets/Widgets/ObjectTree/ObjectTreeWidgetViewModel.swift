import Foundation

@MainActor
final class ObjectTreeWidgetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var isEexpanded: Bool
    
    init(name: String) {
        self.name = name
        self.isEexpanded = false
    }
}
