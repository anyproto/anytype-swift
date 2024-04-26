import Foundation
import SwiftUI

@MainActor
final class ServerConfigurationCoordinatorViewModel: ObservableObject, ServerConfigurationModuleOutput {
    
    @Published var showDocumentPicker: Bool = false

    private let serverConfigurationModuleAssembly: ServerConfigurationModuleAssemblyProtocol
    private let serverDocumentPickerModuleAssembly: ServerDocumentPickerModuleAssemblyProtocol
    
    init(
        serverConfigurationModuleAssembly: ServerConfigurationModuleAssemblyProtocol,
        serverDocumentPickerModuleAssembly: ServerDocumentPickerModuleAssemblyProtocol
    ) {
        self.serverConfigurationModuleAssembly = serverConfigurationModuleAssembly
        self.serverDocumentPickerModuleAssembly = serverDocumentPickerModuleAssembly
    }
    
    func makeSettingsView() -> AnyView {
        serverConfigurationModuleAssembly.make(output: self)
    }
    
    func makeDocumentPickerView() -> AnyView {
        serverDocumentPickerModuleAssembly.make()
    }
    
    // MARK: - ServerConfigurationModuleOutput
    
    func onAddServerSelected() {
        showDocumentPicker.toggle()
    }
}
