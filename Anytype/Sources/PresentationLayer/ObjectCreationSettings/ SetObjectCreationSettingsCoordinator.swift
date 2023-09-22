import UIKit
import Services
import SwiftUI
import AnytypeCore

protocol SetObjectCreationSettingsCoordinatorProtocol: AnyObject {
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

final class SetObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol {
    private let navigationContext: NavigationContextProtocol
    private let setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol
    private let editorAssembly: EditorAssembly
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?
    
    init(
        navigationContext: NavigationContextProtocol,
        setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol,
        editorAssembly: EditorAssembly,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    ) {
        self.navigationContext = navigationContext
        self.setObjectCreationSettingsAssembly = setObjectCreationSettingsAssembly
        self.editorAssembly = editorAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
    }
    
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        dataview: DataviewView,
        onTemplateSelection: @escaping (BlockId?) -> ()
    ) {
        let view = setObjectCreationSettingsAssembly.buildTemplateSelection(
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
            popupLayout: .constantHeight(height: SetObjectCreationSettingsView.height, floatingPanelStyle: true, needBottomInset: false))
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
        let editorPage = editorAssembly.buildEditorModule(
            browser: nil,
            data: .page(
                .init(
                    objectId: blockId,
                    isSupportedForEdit: true,
                    isOpenedForPreview: false,
                    usecase: .templateEditing
                )
            )
        )
        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: onSetAsDefaultTempalte)
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: editorPage.vc,
            onSettingsTap: { [weak self] in
                guard let self = self, let handler = self.handler else { return }
                
                self.objectSettingCoordinator.startFlow(objectId: blockId, delegate: handler, output: nil)
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
