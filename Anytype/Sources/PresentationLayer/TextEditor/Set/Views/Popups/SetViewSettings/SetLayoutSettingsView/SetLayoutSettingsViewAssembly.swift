import SwiftUI

protocol SetLayoutSettingsViewAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetLayoutSettingsCoordinatorOutput?
    ) -> AnyView
}

final class SetLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetLayoutSettingsViewAssemblyProtocol
    
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetLayoutSettingsCoordinatorOutput?
    ) -> AnyView {
        return SetLayoutSettingsView(
            model: SetLayoutSettingsViewModel(
                setDocument: setDocument,
                viewId: viewId,
                output: output,
                dataviewService: self.serviceLocator.dataviewService()
            )
        ).eraseToAnyView()
    }
}
