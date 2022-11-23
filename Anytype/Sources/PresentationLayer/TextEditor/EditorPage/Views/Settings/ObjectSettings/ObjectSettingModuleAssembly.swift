import Foundation
import UIKit

protocol ObjectSettingModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol, output: ObjectSettingswModelOutput) -> UIViewController
}

final class ObjectSettingModuleAssembly: ObjectSettingModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectSettingModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, output: ObjectSettingswModelOutput) -> UIViewController {
        
        let viewModel = ObjectSettingsViewModel(
            document: document,
            objectDetailsService: serviceLocator.detailsService(objectId: document.objectId),
            output: output
        )
        let view = ObjectSettingsView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: view, floatingPanelStyle: true)
        viewModel.onDismiss = { [weak popup] in popup?.close() }
        
        return popup
    }
}
