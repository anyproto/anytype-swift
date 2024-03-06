import Services
import UIKit

protocol ObjectSettingsModuleDelegate: AnyObject {
    func didCreateLinkToItself(selfName: String, data: EditorScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
}

@MainActor
protocol ObjectSettingModuleAssemblyProtocol {
    func make(
        document: BaseDocumentProtocol,
        output: ObjectSettingsModelOutput,
        delegate: ObjectSettingsModuleDelegate,
        actionHandler: @escaping (ObjectSettingsAction) -> Void
    ) -> UIViewController
}

@MainActor
final class ObjectSettingModuleAssembly: ObjectSettingModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectSettingModuleAssemblyProtocol
    
    func make(
        document: BaseDocumentProtocol,
        output: ObjectSettingsModelOutput,
        delegate: ObjectSettingsModuleDelegate,
        actionHandler: @escaping (ObjectSettingsAction) -> Void
    ) -> UIViewController {
        let viewModel = ObjectSettingsViewModel(
            document: document,
            objectDetailsService: serviceLocator.detailsService(objectId: document.objectId),
            objectActionsService: serviceLocator.objectActionsService(),
            blockService: serviceLocator.blockService(),
            templatesService: serviceLocator.templatesService,
            output: output,
            delegate: delegate,
            blockWidgetService: serviceLocator.blockWidgetService(),
            activeWorkpaceStorage: serviceLocator.activeWorkspaceStorage(),
            settingsActionHandler: actionHandler,
            documentsProvider: serviceLocator.documentsProvider
        )
        let view = ObjectSettingsView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: view, floatingPanelStyle: true)
        viewModel.onDismiss = { [weak popup] in popup?.dismiss(animated: true) }
        
        return popup
    }
}
