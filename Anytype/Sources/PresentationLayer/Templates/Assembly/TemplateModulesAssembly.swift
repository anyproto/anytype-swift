import Services
import SwiftUI

protocol TemplateModulesAssemblyProtocol {
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        dataView: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> Void,
        templateEditingHandler: @escaping ((BlockId) -> Void)
    ) -> TemplatesSelectionView
}

final class TemplateModulesAssembly: TemplateModulesAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        dataView: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> Void,
        templateEditingHandler: @escaping ((BlockId) -> Void)
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
                templatesService: serviceLocator.templatesService,
                onTemplateSelection: onTemplateSelection,
                templateEditingHandler: templateEditingHandler
            )
        )
    }
}
