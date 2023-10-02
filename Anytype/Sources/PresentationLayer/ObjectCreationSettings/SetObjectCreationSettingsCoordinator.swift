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
    
    func showTemplateEditing(
        setting: ObjectCreationSetting,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    ) {
        let editorPage = editorAssembly.buildPageModule(browser: nil, data: .init(
            objectId: setting.templateId,
            spaceId: setting.spaceId,
            isSupportedForEdit: true,
            isOpenedForPreview: false,
            usecase: .templateEditing
        ))
       
        let viewModel = editorPage.0.viewModel
        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: onSetAsDefaultTempalte)
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: editorPage.0,
            onSettingsTap: { [weak self, weak viewModel] in
                guard let self = self, let handler = self.handler else { return }
                
                self.objectSettingCoordinator.startFlow(
                    objectId: setting.templateId,
                    delegate: handler,
                    output: nil,
                    objectSettingsHandler: {
                        viewModel?.handleSettingsAction(action: $0)
                    }
                )
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
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.changeType,
            spaceId: setDocument.spaceId,
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
