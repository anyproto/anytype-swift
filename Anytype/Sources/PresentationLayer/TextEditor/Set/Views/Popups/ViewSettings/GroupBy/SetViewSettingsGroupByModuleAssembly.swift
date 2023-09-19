import SwiftUI
import Services

protocol SetViewSettingsGroupByModuleAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void) -> AnyView
}

final class SetViewSettingsGroupByModuleAssembly: SetViewSettingsGroupByModuleAssemblyProtocol {
    
    // MARK: - SetViewSettingsGroupByModuleAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void) -> AnyView {
        return CheckPopupView(
            viewModel: SetViewSettingsGroupByViewModel(
                setDocument: setDocument,
                onSelect: onSelect
            )
        ).eraseToAnyView()
    }
}
