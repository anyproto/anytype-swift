import UIKit
import SwiftUI
import Combine
import Services
import AnytypeCore

protocol TemplatesCoordinatorProtocol {
    func showTemplatesPicker(
        document: BaseDocumentProtocol,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    )
}

final class TemplatesCoordinator: TemplatesCoordinatorProtocol {
    private weak var rootViewController: UIViewController?
    private let editorPageAssembly: EditorAssembly
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?

    init(
        rootViewController: UIViewController,
        editorPageAssembly: EditorAssembly,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    ) {
        self.rootViewController = rootViewController
        self.editorPageAssembly = editorPageAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
    }

    @MainActor
    func showTemplatesPicker(
        document: BaseDocumentProtocol,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    ) {
        guard let rootViewController else { return }

        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: onSetAsDefaultTempalte)
        let picker = TemplatePickerView(
            viewModel: .init(
                output: self,
                document: document,
                objectService: ServiceLocator.shared.objectActionsService(), 
                templatesSubscriptionService: ServiceLocator.shared.templatesSubscription()
            )
        )
        let hostViewController = UIHostingController(rootView: picker)
        hostViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(hostViewController, animated: true, completion: nil)
    }
}

extension TemplatesCoordinator: TemplatePickerViewModuleOutput {
    func onTemplatesChanged(_ templates: [ObjectDetails], completion: ([TemplatePickerData]) -> Void) {
        let editorsViews = templates.map { template in
            let editorController = editorPageAssembly.buildPageModule(browser: nil, data: .init(
                objectId: template.id,
                spaceId: template.spaceId,
                isSupportedForEdit: true,
                isOpenedForPreview: false,
                usecase: .templateEditing
            )).0
            return TemplatePickerData(template: template, editorController: editorController)
        }
        completion(editorsViews)
    }
    
    func selectionOptionsView(_ provider: OptionsItemProvider) -> AnyView {
        SelectionOptionsView(viewModel: SelectionOptionsViewModel(itemProvider: provider))
            .eraseToAnyView()
    }
    
    func onTemplateSettingsTap(_ model: TemplatePickerViewModel.Item.TemplateModel) {
        guard let handler else { return }
        objectSettingCoordinator.startFlow(
            objectId: model.object.id,
            delegate: handler,
            output: nil,
            objectSettingsHandler: {
                model.viewModel.handleSettingsAction(action: $0)
            }
        )
    }
    
    func setAsDefaultBlankTemplate() {
        handler?.useAsTemplateAction(TemplateType.blank.id)
    }
    
    func onClose() {
        rootViewController?.dismiss(animated: true, completion: nil)
    }
}
