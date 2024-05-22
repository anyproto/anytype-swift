import UIKit
import Services
import SwiftUI
import AnytypeCore

@MainActor
protocol SetObjectCreationSettingsCoordinatorProtocol: AnyObject {
    func showSetObjectCreationSettings(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    )
    
    func showTemplateEditing(
        setting: ObjectCreationSetting,
        onTemplateSelection: (() -> Void)?,
        onSetAsDefaultTempalte: @escaping (String) -> Void,
        completion: (() -> Void)?
    )
}

final class SetObjectCreationSettingsCoordinator: 
    SetObjectCreationSettingsCoordinatorProtocol,
    ObjectSettingsCoordinatorOutput,
    SetObjectCreationSettingsOutput
{
    @Injected(\.legacyNavigationContext)
    private var navigationContext: NavigationContextProtocol
    
    private var useAsTemplateAction: ((String) -> Void)?
    private var onTemplateSelection: ((ObjectCreationSetting) -> Void)?
    
    private var editorModuleInput: EditorPageModuleInput?
    
    nonisolated init() {}
    
    func showSetObjectCreationSettings(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        self.onTemplateSelection = onTemplateSelection
        
        let view = SetObjectCreationSettingsView(
            setDocument: setDocument,
            viewId: viewId,
            output: self
        )

        let viewModel = AnytypePopupViewModel(
            contentView: view,
            popupLayout: .constantHeight(
                height: SetObjectCreationSettingsView.height,
                floatingPanelStyle: true,
                needBottomInset: false)
        )
        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: true, skipThroughGestures: false)
        )
        navigationContext.present(popup)
    }
    
    func showTemplateEditing(
        setting: ObjectCreationSetting,
        onTemplateSelection: (() -> Void)?,
        onSetAsDefaultTempalte: @escaping (String) -> Void,
        completion: (() -> Void)?
    ) {
        let editorView = EditorPageCoordinatorView(
            data: EditorPageObject(
                objectId: setting.templateId,
                spaceId: setting.spaceId,
                isOpenedForPreview: false,
                usecase: .templateEditing
            ), 
            showHeader: false,
            setupEditorInput: { [weak self] input, _ in
                self?.editorModuleInput = input
            }
        )
        
        self.useAsTemplateAction = onSetAsDefaultTempalte
        
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: UIHostingController(rootView: editorView),
            onSettingsTap: { [weak self] in
                guard let self = self else { return }
                editorModuleInput?.showSettings(output: self)
            },
            onSelectTemplateTap: onTemplateSelection
        )

        navigationContext.present(editingTemplateViewController, completion: completion)
    }
    
    private func showTypesSearch(
        setDocument: SetDocumentProtocol,
        onSelect: @escaping (ObjectType) -> ()
    ) {
        let view = ObjectTypeSearchView(
            title: Loc.changeType,
            spaceId: setDocument.spaceId,
            settings: .setByRelationNewObject
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    // MARK: - ObjectSettingsCoordinatorOutput
    func closeEditor() {
        navigationContext.dismissTopPresented(animated: true, completion: nil)
    }
    
    func showEditorScreen(data: EditorScreenData) {}
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateTemplate(templateId: String) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didTapUseTemplateAsDefault(templateId: String) {
        useAsTemplateAction?(templateId)
    }
    
    func didUndoRedo() {
        anytypeAssertionFailure("Undo/redo is not available")
    }
    
    // MARK: - SetObjectCreationSettingsOutput
    
    func onTemplateSelection(setting: ObjectCreationSetting) {
        navigationContext.dismissTopPresented(animated: true) { [weak self] in
            self?.onTemplateSelection?(setting)
        }
    }
    
    func onObjectTypesSearchAction(setDocument: SetDocumentProtocol, completion: @escaping (ObjectType) -> Void) {
        showTypesSearch(setDocument: setDocument, onSelect: completion)
    }
    
    func templateEditingHandler(
        setting: ObjectCreationSetting,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    ) {
        showTemplateEditing(
            setting: setting,
            onTemplateSelection: { [weak self] in
                self?.navigationContext.dismissAllPresented(animated: true) {
                    onSetAsDefaultTempalte(setting.templateId)
                    self?.onTemplateSelection?(setting)
                }
            },
            onSetAsDefaultTempalte: { [weak self] templateId in
                self?.navigationContext.dismissTopPresented(animated: true, completion: {
                    onSetAsDefaultTempalte(templateId)
                })
            },
            completion: nil
        )
    }
}
