import SwiftUI

protocol SetLayoutSettingsViewAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol, output: SetLayoutSettingsCoordinatorOutput?) -> AnyView
}

final class SetLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetLayoutSettingsViewAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol, output: SetLayoutSettingsCoordinatorOutput?) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.inlineParameters?.blockId
        )
        return SetLayoutSettingsView(
            model: SetLayoutSettingsViewModel(
                setDocument: setDocument,
                output: output,
                dataviewService: dataviewService
            )
        ).eraseToAnyView()
    }
}
