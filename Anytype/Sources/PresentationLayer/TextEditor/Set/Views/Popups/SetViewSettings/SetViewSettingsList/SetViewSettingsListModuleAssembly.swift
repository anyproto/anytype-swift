import SwiftUI

protocol SetViewSettingsListModuleAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        activeViewId: String,
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
    func make(setDocument: SetDocumentProtocol, activeViewId: String, output: SetViewSettingsCoordinatorOutput?) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId
        )
        let templateInteractorProvider: TemplateSelectionInteractorProvider?
        if setDocument.isTypeSet() {
            templateInteractorProvider = DataviewTemplateSelectionInteractorProvider(
                setDocument: setDocument,
                dataView: setDocument.activeView,
                objectTypeProvider: serviceLocator.objectTypeProvider(),
                subscriptionService: TemplatesSubscriptionService(subscriptionService: serviceLocator.subscriptionService()),
                dataviewService: dataviewService
            )
        } else {
            templateInteractorProvider = nil
        }
        return SetViewSettingsList(
            model: SetViewSettingsListModel(
                setDocument: setDocument,
                activeViewId: activeViewId,
                dataviewService: dataviewService,
                templatesInteractor: self.serviceLocator.setTemplatesInteractor,
                templateInteractorProvider: templateInteractorProvider,
                output: output
            )
        ).eraseToAnyView()
    }
}
