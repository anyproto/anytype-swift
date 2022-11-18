import SwiftUI
import BlocksModels

final class ObjectSettingAssembly {
    
    func settingsPopup(document: BaseDocumentProtocol, router: EditorRouterProtocol) -> UIViewController {
        
        let viewModel = ObjectSettingsViewModel(
            document: document,
            objectDetailsService: ServiceLocator.shared.detailsService(objectId: document.objectId),
            router: router
        )
        let view = ObjectSettingsView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: view, floatingPanelStyle: true)
        viewModel.onDismiss = { [weak popup] in popup?.close() }
        
        return popup
    }
}
