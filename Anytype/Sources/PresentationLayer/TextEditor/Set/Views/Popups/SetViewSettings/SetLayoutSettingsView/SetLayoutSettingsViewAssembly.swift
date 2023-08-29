import SwiftUI

protocol SetLayoutSettingsViewAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView
}

final class SetLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol {
    
    // MARK: - SetLayoutSettingsViewAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView {
        return SetLayoutSettingsView(
            viewModel: SetLayoutSettingsViewModel(setDocument: setDocument)
        ).eraseToAnyView()
    }
}
