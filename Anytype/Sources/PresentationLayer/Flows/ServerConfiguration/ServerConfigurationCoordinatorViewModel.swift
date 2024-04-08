import Foundation
import SwiftUI

@MainActor
final class ServerConfigurationCoordinatorViewModel: ObservableObject, ServerConfigurationModuleOutput {
    
    @Published var showDocumentPicker: Bool = false

    private let serverDocumentPickerModuleAssembly: ServerDocumentPickerModuleAssemblyProtocol
    
    init(serverDocumentPickerModuleAssembly: ServerDocumentPickerModuleAssemblyProtocol) {
        self.serverDocumentPickerModuleAssembly = serverDocumentPickerModuleAssembly
    }
    
    func makeDocumentPickerView() -> AnyView {
        serverDocumentPickerModuleAssembly.make()
    }
    
    // MARK: - ServerConfigurationModuleOutput
    
    func onAddServerSelected() {
        showDocumentPicker.toggle()
    }
}
