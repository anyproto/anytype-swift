import SwiftUI

@MainActor
final class SetLayoutSettingsViewModel: ObservableObject {
    
    private let setDocument: SetDocumentProtocol
    
    init(setDocument: SetDocumentProtocol) {
        self.setDocument = setDocument
    }
}
