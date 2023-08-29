import SwiftUI

protocol SetLayoutSettingsViewAssemblyProtocol {
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView
}

final class SetLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetLayoutSettingsViewAssemblyProtocol
    
    @MainActor
    func make(setDocument: SetDocumentProtocol) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId
        )
        return SetLayoutSettingsView(
            model: SetLayoutSettingsViewModel(
                setDocument: setDocument,
                dataviewService: dataviewService
            )
        ).eraseToAnyView()
    }
}
