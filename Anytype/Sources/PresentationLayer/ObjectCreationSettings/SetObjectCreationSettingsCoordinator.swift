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
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void,
        completion: (() -> Void)?
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
                        model?.setTemplateAsDefault(templateId: setting.templateId, showMessage: false)
                        onTemplateSelection(setting)
                    }
                },
                onSetAsDefaultTempalte: { templateId in
                    model?.setTemplateAsDefault(templateId: templateId, showMessage: true)
                    navigationContext?.dismissTopPresented(animated: true, completion: nil)
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
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void,
        completion: (() -> Void)?
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
            }, 
            onSelectTemplateTap: onTemplateSelection
        )

        navigationContext.present(editingTemplateViewController, completion: completion)
    }
    
    private func showTypesSearch(
        setDocument: SetDocumentProtocol,
        onSelect: @escaping (ObjectType) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.changeType,
            spaceId: setDocument.spaceId,
            showBookmark: true,
            showSetAndCollection: true,
            browser: nil
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type)
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
