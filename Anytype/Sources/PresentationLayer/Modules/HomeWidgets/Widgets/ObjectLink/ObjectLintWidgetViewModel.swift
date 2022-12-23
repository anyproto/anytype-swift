import Foundation

@MainActor
final class ObjectLintWidgetViewModel: ObservableObject {
    
    @Published var name: String
    @Published var isEexpanded: Bool
    
    var objectId: UUID = UUID()
    
    init(name: String) {
        self.name = name
        self.isEexpanded = false
    }
}
