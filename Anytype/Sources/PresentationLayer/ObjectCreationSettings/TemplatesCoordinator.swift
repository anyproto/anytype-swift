import UIKit
import SwiftUI
import Combine
import Services
import AnytypeCore

protocol TemplatesCoordinatorProtocol {
    @MainActor
    func showTemplatesPicker(
        document: some BaseDocumentProtocol,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    )
    
    @MainActor
    func showTemplatesPicker(
        data: TemplatePickerViewModelData,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    )
}

final class TemplatesCoordinator: TemplatesCoordinatorProtocol, ObjectSettingsCoordinatorOutput {
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.legacyToastPresenter)
    private var toastPresenter: any ToastPresenterProtocol
    
    private var editorModuleInputs = [String: any EditorPageModuleInput]()
    private var onSetAsDefaultTempalte: ((String) -> Void)?
    
    nonisolated init() {}
    
    @MainActor
    func showTemplatesPicker(
        document: some BaseDocumentProtocol,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    ) {
        let data = TemplatePickerViewModelData(
            mode: .objectTemplate(objectId: document.objectId),
            typeId: document.details?.objectType.id,
            spaceId: document.spaceId,
            defaultTemplateId: nil
        )
        showTemplatesPicker(data: data, onSetAsDefaultTempalte: onSetAsDefaultTempalte)
    }
    
    @MainActor
    func showTemplatesPicker(
        data: TemplatePickerViewModelData,
        onSetAsDefaultTempalte: @escaping (String) -> Void
    ) {
        self.onSetAsDefaultTempalte = onSetAsDefaultTempalte
        let picker = TemplatePickerView(viewModel: .init(data: data, output: self))
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
                    usecase: .embedded
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
    
    func selectionOptionsView(_ provider: some OptionsItemProvider) -> AnyView {
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
    
    func showEditorScreen(data: ScreenData) {}
    
    func didCreateLinkToItself(selfName: String, data: ScreenData) {}
    
    func didCreateTemplate(templateId: String) {}
    
    func didTapUseTemplateAsDefault(templateId: String) {
        onSetAsDefaultTempalte?(templateId)
    }
    
    func didUndoRedo() {
        anytypeAssertionFailure("Undo/redo is not available")
    }
    
    func versionRestored(_ text: String) {
        toastPresenter.show(message: Loc.VersionHistory.Toast.message(text))
    }
}
