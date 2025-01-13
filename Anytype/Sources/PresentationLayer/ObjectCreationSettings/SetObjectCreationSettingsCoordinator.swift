import UIKit
import Services
import SwiftUI
import AnytypeCore

@MainActor
protocol SetObjectCreationSettingsCoordinatorProtocol: AnyObject, SetObjectCreationSettingsOutput {
    func showTemplateEditing(
        setting: ObjectCreationSetting,
        onTemplateSelection: (() -> Void)?,
        onSetAsDefaultTempalte: @escaping (String) -> Void,
        completion: (() -> Void)?
    )
}

@MainActor
final class SetObjectCreationSettingsCoordinator:
    SetObjectCreationSettingsCoordinatorProtocol,
    ObjectSettingsCoordinatorOutput,
    SetObjectCreationSettingsOutput
{
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    
    private var useAsTemplateAction: ((String) -> Void)?
    private var editorModuleInput: (any EditorPageModuleInput)?
    
    nonisolated init() {}
    
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
                usecase: .embedded
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
        setDocument: some SetDocumentProtocol,
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
    
    func showEditorScreen(data: ScreenData) {}
    
    func didCreateLinkToItself(selfName: String, data: ScreenData) {
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
    
    func versionRestored(_ text: String) {
        toastPresenter.show(message: Loc.VersionHistory.Toast.message(text))
    }
    
    // MARK: - SetObjectCreationSettingsOutput
    
    func onObjectTypesSearchAction(setDocument: some SetDocumentProtocol, completion: @escaping (ObjectType) -> Void) {
        showTypesSearch(setDocument: setDocument, onSelect: completion)
    }
    
    func templateEditingHandler(
        setting: ObjectCreationSetting,
        onSetAsDefaultTempalte: @escaping (String) -> Void,
        onTemplateSelection: ((ObjectCreationSetting) -> Void)?
    ) {
        showTemplateEditing(
            setting: setting,
            onTemplateSelection: { [weak self] in
                self?.navigationContext.dismissAllPresented(animated: true) {
                    onSetAsDefaultTempalte(setting.templateId)
                    onTemplateSelection?(setting)
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
