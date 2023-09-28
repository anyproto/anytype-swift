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
        let setObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol?
        if setDocument.isTypeSet() {
            setObjectCreationSettingsInteractor = SetObjectCreationSettingsInteractor(
                mode: .default,
                setDocument: setDocument,
                viewId: viewId,
                objectTypesProvider: serviceLocator.objectTypeProvider(),
                subscriptionService: TemplatesSubscriptionService(subscriptionService: serviceLocator.subscriptionService()),
                dataviewService: dataviewService
            )
        } else {
            setObjectCreationSettingsInteractor = nil
        }
        return SetViewSettingsList(
            model: SetViewSettingsListModel(
                setDocument: setDocument,
                viewId: viewId,
                mode: mode,
                dataviewService: dataviewService,
                templatesInteractor: self.serviceLocator.setTemplatesInteractor,
                setObjectCreationSettingsInteractor: setObjectCreationSettingsInteractor,
                output: output
            )
        ).eraseToAnyView()
    }
}
