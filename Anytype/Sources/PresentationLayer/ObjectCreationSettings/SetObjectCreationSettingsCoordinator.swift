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

final class SetObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol {
    private let navigationContext: NavigationContextProtocol
    private let setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let objectTypeSearchModuleAssembly:ObjectTypeSearchModuleAssemblyProtocol
    private let editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?
    
    private var editorModuleInput: EditorPageModuleInput?
    
    init(
        navigationContext: NavigationContextProtocol,
        setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        objectTypeSearchModuleAssembly:ObjectTypeSearchModuleAssemblyProtocol,
        editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.setObjectCreationSettingsAssembly = setObjectCreationSettingsAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.objectTypeSearchModuleAssembly = objectTypeSearchModuleAssembly
        self.editorPageCoordinatorAssembly = editorPageCoordinatorAssembly
    }
    
    func showSetObjectCreationSettings(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        let view = setObjectCreationSettingsAssembly.build(
            setDocument: setDocument,
            viewId: viewId,
            onTemplateSelection: { [weak self] setting in
                guard let self else { return }
                navigationContext.dismissTopPresented(animated: true) {
                    onTemplateSelection(setting)
                }
            }
        )
        let model = view.model
        
        view.model.onObjectTypesSearchAction = { [weak self, weak model] in
            self?.showTypesSearch(
                setDocument: setDocument,
                onSelect: { objectType in
                    model?.setObjectType(objectType)
                }
            )
        }
        
        view.model.templateEditingHandler = { [weak self, weak model, weak navigationContext] setting in
            self?.showTemplateEditing(
                setting: setting,
                onTemplateSelection: {
                    navigationContext?.dismissAllPresented(animated: true) {
                        model?.setTemplateAsDefault(templateId: setting.templateId)
                        onTemplateSelection(setting)
                    }
                },
                onSetAsDefaultTempalte: { templateId in
                    navigationContext?.dismissTopPresented(animated: true, completion: {
                        model?.setTemplateAsDefaultForType(templateId: templateId)
                    })
                },
                completion: nil
            )
        }

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
        let editorView = editorPageCoordinatorAssembly.make(
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
        
        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: onSetAsDefaultTempalte)
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: UIHostingController(rootView: editorView),
            onSettingsTap: { [weak self] in
                guard let self = self, let handler = self.handler else { return }
                editorModuleInput?.showSettings(delegate: handler, output: self)
            },
            onSelectTemplateTap: onTemplateSelection
        )

        navigationContext.present(editingTemplateViewController, completion: completion)
    }
    
    private func showTypesSearch(
        setDocument: SetDocumentProtocol,
        onSelect: @escaping (ObjectType) -> ()
    ) {
        if FeatureFlags.newTypePicker {
            let view = objectTypeSearchModuleAssembly.makeDefaultTypeSearch(
                title: Loc.changeType,
                spaceId: setDocument.spaceId,
                showPins: false,
                showLists: true, 
                showFiles: false
            ) { [weak self] type in
                self?.navigationContext.dismissTopPresented()
                onSelect(type)
            }
            
            navigationContext.presentSwiftUIView(view: view)
        } else {
            let view = newSearchModuleAssembly.objectTypeSearchModule(
                title: Loc.changeType,
                spaceId: setDocument.spaceId,
                showSetAndCollection: true
            ) { [weak self] type in
                self?.navigationContext.dismissTopPresented()
                onSelect(type)
            }
            
            navigationContext.presentSwiftUIView(view: view)
        }
    }
}

extension SetObjectCreationSettingsCoordinator: ObjectSettingsCoordinatorOutput {
    func closeEditor() {
        navigationContext.dismissTopPresented(animated: true, completion: nil)
    }
    
    func showEditorScreen(data: EditorScreenData) {}
}

final class TemplateSelectionObjectSettingsHandler: ObjectSettingsModuleDelegate {
    let useAsTemplateAction: (String) -> Void
    
    init(useAsTemplateAction: @escaping (String) -> Void) {
        self.useAsTemplateAction = useAsTemplateAction
    }
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateTemplate(templateId: String) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didTapUseTemplateAsDefault(templateId: String) {
        useAsTemplateAction(templateId)
    }
}
