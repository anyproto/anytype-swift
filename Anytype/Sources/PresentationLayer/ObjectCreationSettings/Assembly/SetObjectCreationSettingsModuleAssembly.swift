import Services
import SwiftUI

protocol SetObjectCreationSettingsModuleAssemblyProtocol {
    @MainActor
    func build(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> Void
    ) -> SetObjectCreationSettingsView
}

final class SetObjectCreationSettingsModuleAssembly: SetObjectCreationSettingsModuleAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    private let uiHelperDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelperDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelperDI = uiHelperDI
    }
    
    @MainActor
    func build(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> Void
    ) -> SetObjectCreationSettingsView {
        SetObjectCreationSettingsView(
            model: SetObjectCreationSettingsViewModel(
                interactor: SetObjectCreationSettingsInteractor(
                    setDocument: setDocument,
                    viewId: viewId,
                    objectTypesProvider: serviceLocator.objectTypeProvider(),
                    typesService: serviceLocator.typesService(),
                    subscriptionService: serviceLocator.templatesSubscription(),
                    dataviewService: serviceLocator.dataviewService()
                ),
                setDocument: setDocument,
                templatesService: serviceLocator.templatesService,
                toastPresenter: uiHelperDI.toastPresenter(),
                onTemplateSelection: onTemplateSelection
            )
        )
    }
}
