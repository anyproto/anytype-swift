import UIKit
import Services
import SwiftUI

protocol TemplateSelectionCoordinatorProtocol: AnyObject {
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        dataview: DataviewView,
        onTemplateSelection: @escaping (BlockId) -> ()
    )
}

final class TemplateSelectionCoordinator: TemplateSelectionCoordinatorProtocol {
    private let navigationContext: NavigationContextProtocol
    private let templatesModuleAssembly: TemplateModulesAssembly
    
    init(
        navigationContext: NavigationContextProtocol,
        templatesModulesAssembly: TemplateModulesAssembly
    ) {
        self.navigationContext = navigationContext
        self.templatesModuleAssembly = templatesModulesAssembly
    }
    
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        dataview: DataviewView,
        onTemplateSelection: @escaping (BlockId) -> ()
    ) {
        let view = templatesModuleAssembly.buildTemplateSelection(
            setDocument: setDocument,
            dataView: dataview,
            onTemplateSelection: { [weak navigationContext] templateId in
                navigationContext?.dismissTopPresented(animated: true) {
                    onTemplateSelection(templateId)
                }
            }
        )
        
        view.model.templateOptionsHandler = { [weak self] closure in
            self?.showTemplateOptions(handler: closure)
        }
        
        let viewModel = AnytypePopupViewModel(contentView: view, popupLayout: .intrinsic)
        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true, skipThroughGestures: false),
            onDismiss: { }
        )
        navigationContext.present(popup)
    }
    
    private func showTemplateOptions(handler: @escaping (TemplateOptionAction) -> Void) {
        let templateActions = TemplateOptionAction.allCases.map { option in
            UIAlertAction(
                title: option.title,
                style: option.style
            ) { _ in
                handler(option)
            }
        }
        let cancelAction = UIAlertAction(title: Loc.cancel, style: .cancel)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        templateActions.forEach(alertController.addAction(_:))
        alertController.addAction(cancelAction)
        
        navigationContext.present(alertController)
    }
}

