import SwiftUI

protocol SetViewSettingsListModuleAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        output: SetViewSettingsCoordinatorOutput?
    ) -> AnyView
}

final class SetViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetViewSettingsListModuleAssemblyProtocol
    
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        output: SetViewSettingsCoordinatorOutput?
    ) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId
        )
        return SetViewSettingsList(
            model: SetViewSettingsListModel(
                setDocument: setDocument,
                viewId: viewId,
                mode: mode,
                dataviewService: dataviewService,
                output: output
            )
        ).eraseToAnyView()
    }
}
