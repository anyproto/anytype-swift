import SwiftUI

protocol SetViewSettingsImagePreviewModuleAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void) -> AnyView
}

final class SetViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol {
    
    // MARK: - SetViewSettingsImagePreviewModuleAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void) -> AnyView {
        return SetViewSettingsImagePreviewView(
            viewModel: SetViewSettingsImagePreviewViewModel(
                setDocument: setDocument,
                onSelect: onSelect
            )
        ).eraseToAnyView()
    }
}
