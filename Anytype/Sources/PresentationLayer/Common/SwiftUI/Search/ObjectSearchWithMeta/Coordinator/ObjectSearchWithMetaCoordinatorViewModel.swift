import SwiftUI
import Services

@MainActor
@Observable
final class ObjectSearchWithMetaCoordinatorViewModel {

    let data: ObjectSearchWithMetaModuleData

    var dismiss = false
    
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
