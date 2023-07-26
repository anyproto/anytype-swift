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
}

final class TemplateSelectionCoordinator: TemplateSelectionCoordinatorProtocol {
    private let navigationContext: NavigationContextProtocol
    private let templatesModuleAssembly: TemplateModulesAssembly
    private let editorAssembly: EditorAssembly
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    
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
            },
            templateEditingHandler: { [weak self] templateId in
                self?.showTemplateEditing(blockId: templateId, setDocument: setDocument, onTemplateSelection: onTemplateSelection)
            }
        )
        
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
    
    private func showTemplateEditing(blockId: BlockId, setDocument: SetDocumentProtocol, onTemplateSelection: @escaping (BlockId) -> Void) {
        let editorPage = editorAssembly.buildEditorModule(
            browser: nil,
            data: .page(.init(objectId: blockId, spaceId: setDocument.spaceId, isSupportedForEdit: true, isOpenedForPreview: false))
        )
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: editorPage.vc,
            onSettingsTap: { [weak self] in
                guard let self = self else { return }
                
                self.objectSettingCoordinator.startFlow(objectId: blockId, delegate: self)
            }, onSelectTemplateTap: { [weak self] in
                self?.navigationContext.dismissAllPresented(animated: true) {
                    onTemplateSelection(blockId)
                }
            }
        )

        navigationContext.present(editingTemplateViewController)
    }
}

extension TemplateSelectionCoordinator: ObjectSettingsModuleDelegate {
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
}
