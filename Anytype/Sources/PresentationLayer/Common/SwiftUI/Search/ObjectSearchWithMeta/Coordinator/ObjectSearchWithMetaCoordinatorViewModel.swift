import SwiftUI
import Services

@MainActor
final class ObjectSearchWithMetaCoordinatorViewModel: ObservableObject {
    
    let data: ObjectSearchWithMetaModuleData
    
    @Published var dismiss = false
    
    init(data: ObjectSearchWithMetaModuleData) {
        self.data = data
    }
    
    func handleDismissResult(_ result: ChatCreateObjectDismissResult) {
        switch result {
        case .attachedToChat, .pageOpened:
            dismiss.toggle()
        case .canceled:
            break
        }
    }
}
