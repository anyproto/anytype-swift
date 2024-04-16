import SwiftUI
import Services

protocol SetLayoutSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol, viewId: String) -> AnyView
}

final class SetLayoutSettingsCoordinatorAssembly: SetLayoutSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetLayoutSettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol, viewId: String) -> AnyView {
        return SetLayoutSettingsCoordinatorView(
            model: SetLayoutSettingsCoordinatorViewModel(
                setDocument: setDocument,
                viewId: viewId,
                setViewSettingsImagePreviewModuleAssembly: self.modulesDI.setViewSettingsImagePreview()
            )
        ).eraseToAnyView()
    }
}
