import Foundation
import SwiftUI

@MainActor
@Observable
final class ServerConfigurationCoordinatorViewModel: ServerConfigurationModuleOutput {

    var showDocumentPicker: Bool = false
    
    // MARK: - ServerConfigurationModuleOutput
    
    func onAddServerSelected() {
        showDocumentPicker.toggle()
    }
}
