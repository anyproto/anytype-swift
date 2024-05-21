import UIKit
import SwiftUI
import Combine
import Services
import AnytypeCore

protocol TemplatesCoordinatorProtocol {
    func showTemplatesPicker(
        document: BaseDocumentProtocol,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    )
}

final class TemplatesCoordinator: TemplatesCoordinatorProtocol, ObjectSettingsCoordinatorOutput {
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: NavigationContextProtocol
    
    private var editorModuleInputs = [String: EditorPageModuleInput]()
    private var onSetAsDefaultTempalte: ((String) -> Void)?
    
    nonisolated init() {}
    
    @MainActor
    func showTemplatesPicker(
        document: BaseDocumentProtocol,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    ) {
        self.onSetAsDefaultTempalte = onSetAsDefaultTempalte
        let picker = TemplatePickerView(
            viewModel: .init(output: self, document: document)
        )
        let hostViewController = UIHostingController(rootView: picker)
        hostViewController.modalPresentationStyle = .fullScreen
        navigationContext.present(hostViewController, animated: true, completion: nil)
    }
}

extension TemplatesCoordinator: TemplatePickerViewModuleOutput {
    func onTemplatesChanged(_ templates: [ObjectDetails], completion: ([TemplatePickerData]) -> Void) {
        editorModuleInputs.removeAll()
        let editorsViews = templates.map { template in
            let editorView = EditorPageCoordinatorView(
                data: EditorPageObject(
                    objectId: template.id,
                    spaceId: template.spaceId,
                    isOpenedForPreview: false,
                    usecase: .templateEditing
                ),
                showHeader: false,
                setupEditorInput: { [weak self] input, objectId in
                    self?.editorModuleInputs[objectId] = input
                }
            ).eraseToAnyView()
            return TemplatePickerData(template: template, editorView: editorView)
        }
        completion(editorsViews)
    }
    
    func selectionOptionsView(_ provider: OptionsItemProvider) -> AnyView {
        SelectionOptionsView(viewModel: SelectionOptionsViewModel(itemProvider: provider))
            .eraseToAnyView()
    }
    
    func onTemplateSettingsTap(_ model: TemplatePickerViewModel.Item.TemplateModel) {
        editorModuleInputs[model.object.id]?.showSettings(output: self)
    }
    
    func setAsDefaultBlankTemplate() {
        onSetAsDefaultTempalte?(TemplateType.blank.id)
    }
    
    func onClose() {
        navigationContext.dismissTopPresented(animated: true, completion: nil)
    }
    
    // MARK: - ObjectSettingsCoordinatorOutput
    
    func closeEditor() {}
    
    func showEditorScreen(data: EditorScreenData) {}
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {}
    
    func didCreateTemplate(templateId: String) {}
    
    func didTapUseTemplateAsDefault(templateId: String) {
        onSetAsDefaultTempalte?(templateId)
    }
    
    func didUndoRedo() {
        anytypeAssertionFailure("Undo/redo is not available")
    }
}
