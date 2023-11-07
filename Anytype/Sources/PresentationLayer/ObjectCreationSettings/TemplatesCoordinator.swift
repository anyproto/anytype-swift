import UIKit
import SwiftUI
import Combine
import Services
import AnytypeCore

protocol TemplatesCoordinatorProtocol {
    func showTemplatesPicker(document: BaseDocumentProtocol)
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
    func showTemplatesPicker(document: BaseDocumentProtocol) {
        guard let rootViewController else { return }

        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: { _ in })
        let picker = TemplatePickerView(
            viewModel: .init(
                output: self,
                document: document,
                objectService: ServiceLocator.shared.objectActionsService(), 
                templatesSubscriptionService: ServiceLocator.shared.templatesSubscription(),
                onClose: { [weak rootViewController] in
                    rootViewController?.dismiss(animated: true, completion: nil)
                }, 
                onSettingsTap: { [weak self] model in
                    guard let self, let handler else { return }
                    self.objectSettingCoordinator.startFlow(
                        objectId: model.object.id,
                        delegate: handler,
                        output: nil,
                        objectSettingsHandler: {
                            model.viewModel.handleSettingsAction(action: $0)
                        }
                    )
                }
            )
        )
        let hostViewController = UIHostingController(rootView: picker)
        hostViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(hostViewController, animated: true, completion: nil)
    }
}

extension TemplatesCoordinator: TemplatePickerViewModuleOutput {
    func onTemplatesChanged(_ templates: [ObjectDetails], completion: ([TemplatePickerModel]) -> Void) {
        let editorsViews = templates.map { template in
            let editorController = editorPageAssembly.buildPageModule(browser: nil, data: .init(
                objectId: template.id,
                spaceId: template.spaceId,
                isSupportedForEdit: true,
                isOpenedForPreview: false,
                usecase: .templateEditing
            )).0
            return TemplatePickerModel(template: template, editorController: editorController)
        }
        completion(editorsViews)
    }
}
