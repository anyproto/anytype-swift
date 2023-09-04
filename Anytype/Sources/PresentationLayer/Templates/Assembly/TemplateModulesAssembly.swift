import Services
import SwiftUI

protocol TemplateModulesAssemblyProtocol {
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        dataView: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> Void
    ) -> TemplatesSelectionView
}

final class TemplateModulesAssembly: TemplateModulesAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    private let uiHelperDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelperDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelperDI = uiHelperDI
    }
    
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        dataView: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> Void
    ) -> TemplatesSelectionView {
        TemplatesSelectionView(
            model: .init(
                interactor: DataviewTemplateSelectionInteractorProvider(
                    setDocument: setDocument,
                    dataView: dataView,
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
