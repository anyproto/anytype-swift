import Foundation
import UIKit

protocol ObjectSettingModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol, router: EditorRouterProtocol) -> UIViewController
}

final class ObjectSettingModuleAssembly: ObjectSettingModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectSettingModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, router: EditorRouterProtocol) -> UIViewController {
        
        let viewModel = ObjectSettingsViewModel(
            document: document,
            objectDetailsService: serviceLocator.detailsService(objectId: document.objectId),
            router: router
        )
        let view = ObjectSettingsView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: view, floatingPanelStyle: true)
        viewModel.onDismiss = { [weak popup] in popup?.close() }
        
        return popup
    }
}
