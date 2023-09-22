import Services
import SwiftUI

protocol SetObjectCreationSettingsModuleAssemblyProtocol {
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (BlockId?) -> Void
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
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (BlockId?) -> Void
    ) -> SetObjectCreationSettingsView {
        SetObjectCreationSettingsView(
            model: SetObjectCreationSettingsViewModel(
                interactor: DataviewTemplateSelectionInteractorProvider(
                    setDocument: setDocument,
                    viewId: viewId,
                    objectTypeProvider: serviceLocator.objectTypeProvider(),
                    subscriptionService: TemplatesSubscriptionService(subscriptionService: serviceLocator.subscriptionService()),
                    dataviewService: DataviewService(
                        objectId: setDocument.objectId,
                        blockId: nil,
                        prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
                    )
                ),
                setDocument: setDocument,
                templatesService: serviceLocator.templatesService,
                toastPresenter: uiHelperDI.toastPresenter(),
                onTemplateSelection: onTemplateSelection
            )
        )
    }
}
