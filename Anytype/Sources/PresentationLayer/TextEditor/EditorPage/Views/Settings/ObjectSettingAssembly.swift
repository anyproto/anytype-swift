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
    
    func iconPicker(document: BaseDocumentProtocol) -> UIViewController {
        let viewModel = ObjectIconPickerViewModel(
            document: document,
            fileService: ServiceLocator.shared.fileService(),
            detailsService: ServiceLocator.shared.detailsService(objectId: document.objectId)
        )
        
        let controller = UIHostingController(
            rootView: ObjectIconPicker(viewModel: viewModel)
        )
        
        controller.rootView.dismissHandler = DismissHandler(
            onDismiss:  { [weak controller] in
                controller?.dismiss(animated: true)
            }
        )
        
        return controller
    }
}
