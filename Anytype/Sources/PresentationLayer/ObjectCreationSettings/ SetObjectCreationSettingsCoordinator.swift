import UIKit
import Services
import SwiftUI
import AnytypeCore

protocol SetObjectCreationSettingsCoordinatorProtocol: AnyObject {
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    )
    
    func showTemplateEditing(
        setting: ObjectCreationSetting,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    )
}

final class SetObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol {
    private let navigationContext: NavigationContextProtocol
    private let setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol
    private let editorAssembly: EditorAssembly
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?
    
    init(
        navigationContext: NavigationContextProtocol,
        setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol,
        editorAssembly: EditorAssembly,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    ) {
        self.navigationContext = navigationContext
        self.setObjectCreationSettingsAssembly = setObjectCreationSettingsAssembly
        self.editorAssembly = editorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
    }
    
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        let view = setObjectCreationSettingsAssembly.buildTemplateSelection(
            setDocument: setDocument,
            viewId: viewId,
            onTemplateSelection: { [weak navigationContext] setting in
                navigationContext?.dismissTopPresented(animated: true) {
                    onTemplateSelection(setting)
                }
            }
        )
        let model = view.model
        
        view.model.onObjectTypesSearchAction = { [weak self, weak model] in
            self?.showTypesSearch(
                setDocument: setDocument,
                selectedObjectId: nil,
                onSelect: { objectTypeId in
                    model?.setObjectTypeId(objectTypeId)
                }
            )
        }
        
        view.model.templateEditingHandler = { [weak self, weak model, weak navigationContext] setting in
            self?.showTemplateEditing(
                setting: setting,
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
        setting: ObjectCreationSetting,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    ) {
        let editorPage = editorAssembly.buildEditorModule(
            browser: nil,
            data: .page(
                .init(
                    objectId: setting.templateId,
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
                
                self.objectSettingCoordinator.startFlow(objectId: setting.templateId, delegate: handler, output: nil)
            }, onSelectTemplateTap: { [weak self] in
                self?.navigationContext.dismissAllPresented(animated: true) {
                    onTemplateSelection(setting)
                }
            }
        )

        navigationContext.present(editingTemplateViewController)
    }
    
    private func showTypesSearch(
        setDocument: SetDocumentProtocol,
        selectedObjectId: BlockId?,
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: setDocument.details?.type,
            showBookmark: true,
            showSetAndCollection: true,
            browser: nil
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type.id)
        }

        navigationContext.presentSwiftUIView(view: view)
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
