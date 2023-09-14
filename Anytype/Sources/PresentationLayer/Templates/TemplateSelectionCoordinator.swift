import UIKit
import Services
import SwiftUI
import AnytypeCore

protocol TemplateSelectionCoordinatorProtocol: AnyObject {
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        dataview: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> ()
    )
    
    func showTemplateEditing(
        blockId: BlockId,
        onTemplateSelection: @escaping (BlockId) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    )
}

final class TemplateSelectionCoordinator: TemplateSelectionCoordinatorProtocol {
    private let navigationContext: NavigationContextProtocol
    private let templatesModuleAssembly: TemplateModulesAssembly
    private let editorAssembly: EditorAssembly
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?
    
    init(
        navigationContext: NavigationContextProtocol,
        templatesModulesAssembly: TemplateModulesAssembly,
        editorAssembly: EditorAssembly,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    ) {
        self.navigationContext = navigationContext
        self.templatesModuleAssembly = templatesModulesAssembly
        self.editorAssembly = editorAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
    }
    
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        dataview: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> ()
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
        let model = view.model
        
        view.model.templateEditingHandler = { [weak self, weak model, weak navigationContext] templateId in
            self?.showTemplateEditing(
                blockId: templateId,
                onTemplateSelection: onTemplateSelection,
                onSetAsDefaultTempalte: { templateId in
                    model?.setTemplateAsDefault(templateId: templateId)
                    navigationContext?.dismissTopPresented(animated: true, completion: nil)
                }
            )
        }
        
        let viewModel = AnytypePopupViewModel(
            contentView: view,
            popupLayout: .constantHeight(height: TemplatesSelectionView.height, floatingPanelStyle: true, needBottomInset: false))
        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true, skipThroughGestures: false)
        )
        navigationContext.present(popup)
    }
    
    func showTemplateEditing(
        blockId: BlockId,
        onTemplateSelection: @escaping (BlockId) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    ) {
        let editorPage = editorAssembly.buildPageModule(
            browser: nil,
            data: .init(
                objectId: blockId,
                isSupportedForEdit: true,
                isOpenedForPreview: false,
                usecase: .templateEditing
            )
        )
        let viewModel = editorPage.0.viewModel
        let settingsHandler: (ObjectSettingsAction) -> Void = { [weak viewModel] action in
            viewModel?.handleSettingsAction(action: action)
        }
        
        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: onSetAsDefaultTempalte)
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: editorPage.0,
            onSettingsTap: { [weak self] in
                guard let self = self, let handler = self.handler else { return }
                
                self.objectSettingCoordinator.startFlow(
                    objectId: blockId,
                    delegate: handler,
                    output: nil,
                    objectSettingsHandler: settingsHandler
                )
            }, onSelectTemplateTap: { [weak self] in
                self?.navigationContext.dismissAllPresented(animated: true) {
                    onTemplateSelection(blockId)
                }
            }
        )

        navigationContext.present(editingTemplateViewController)
    }
}

final class TemplateSelectionObjectSettingsHandler: ObjectSettingsModuleDelegate {
    let useAsTemplateAction: (BlockId) -> Void
    
    init(useAsTemplateAction: @escaping (BlockId) -> Void) {
        self.useAsTemplateAction = useAsTemplateAction
    }
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateTemplate(templateId: BlockId) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didTapUseTemplateAsDefault(templateId: BlockId) {
        useAsTemplateAction(templateId)
    }
}
