import UIKit
import Services
import SwiftUI
import AnytypeCore

enum SetObjectCreationSettingsMode {
    case creation
    case `default`
    
    var title: String {
        switch self {
        case .creation:
            return Loc.createObject
        case .default:
            return Loc.Set.View.Settings.DefaultObject.title
        }
    }
}

protocol SetObjectCreationSettingsCoordinatorProtocol: AnyObject {
    @MainActor
    func showSetObjectCreationSettings(
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
    private let mode: SetObjectCreationSettingsMode
    private let navigationContext: NavigationContextProtocol
    private let setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol
    private let editorAssembly: EditorAssembly
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?
    
    init(
        mode: SetObjectCreationSettingsMode,
        navigationContext: NavigationContextProtocol,
        setObjectCreationSettingsAssembly: SetObjectCreationSettingsModuleAssemblyProtocol,
        editorAssembly: EditorAssembly,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    ) {
        self.mode = mode
        self.navigationContext = navigationContext
        self.setObjectCreationSettingsAssembly = setObjectCreationSettingsAssembly
        self.editorAssembly = editorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
    }
    
    @MainActor
    func showSetObjectCreationSettings(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        let view = setObjectCreationSettingsAssembly.build(
            mode: mode,
            setDocument: setDocument,
            viewId: viewId,
            onTemplateSelection: { [weak self] setting in
                guard let self else { return }
                switch mode {
                case .creation:
                    navigationContext.dismissTopPresented(animated: true) {
                        onTemplateSelection(setting)
                    }
                case .default:
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
                    model?.setTemplateAsDefault(templateId: templateId, showMessage: true)
                    navigationContext?.dismissTopPresented(animated: true, completion: nil)
                }
            )
        }
        
        let floatingPanelStyle = mode == .creation
        let viewModel = AnytypePopupViewModel(
            contentView: view,
            popupLayout: .constantHeight(
                height: SetObjectCreationSettingsView.height,
                floatingPanelStyle: floatingPanelStyle,
                needBottomInset: false)
        )
        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: floatingPanelStyle,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true, skipThroughGestures: false)
        )
        navigationContext.present(popup)
    }
    
    @MainActor
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
                guard let self else { return }
                switch mode {
                case .creation:
                    navigationContext.dismissAllPresented(animated: true) {
                        onTemplateSelection(setting)
                    }
                case .default:
                    navigationContext.dismissTopPresented(animated: true) {
                        onTemplateSelection(setting)
                    }
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
