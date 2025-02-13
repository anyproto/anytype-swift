import Combine
import Services
import Foundation

struct AIToolData: Identifiable {
    let id: String
    let completion: (ScreenData) -> Void
}

@MainActor
final class AIToolViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var generateTaskId: String? = nil
    @Published var inProgress = false
    @Published var dismiss = false
    
    private let data: AIToolData
    
    init(data: AIToolData) {
        self.data = data
    }
    
    func generate() async {
        inProgress = true
//        data.completion()
        dismiss = true
    }
    
    func generateTap() {
        generateTaskId = UUID().uuidString
    }
}
