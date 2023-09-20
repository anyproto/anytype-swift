import Services
import UIKit

protocol ObjectSettingsModuleDelegate: AnyObject {
    func didCreateLinkToItself(selfName: String, data: EditorScreenData)
    func didCreateTemplate(templateId: BlockId)
    func didTapUseTemplateAsDefault(templateId: BlockId)
}

protocol ObjectSettingModuleAssemblyProtocol {
    func make(
        document: BaseDocumentProtocol,
        output: ObjectSettingsModelOutput,
        delegate: ObjectSettingsModuleDelegate,
        actionHandler: @escaping (ObjectSettingsAction) -> Void
    ) -> UIViewController
}

final class ObjectSettingModuleAssembly: ObjectSettingModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
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
            blockActionsService: serviceLocator.blockActionsServiceSingle(),
            templatesService: serviceLocator.templatesService,
            output: output,
            delegate: delegate,
            settingsActionHandler: actionHandler
        )
        let view = ObjectSettingsView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: view, floatingPanelStyle: true)
        viewModel.onDismiss = { [weak popup] in popup?.close() }
        
        return popup
    }
}
