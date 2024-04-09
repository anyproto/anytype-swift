import Foundation
import SwiftUI

@MainActor
final class ServerConfigurationCoordinatorViewModel: ObservableObject, ServerConfigurationModuleOutput {
    
    @Published var showDocumentPicker: Bool = false
    
    // MARK: - ServerConfigurationModuleOutput
    
    func onAddServerSelected() {
        showDocumentPicker.toggle()
    }
}
