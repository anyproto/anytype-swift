import UIKit
import SwiftUI
import Combine
import Services
import AnytypeCore

final class TemplatesCoordinator {
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
        availableTemplates: [ObjectDetails]
    ) {
        guard let rootViewController = rootViewController else {
            return
        }

        var items = availableTemplates.enumerated().map { info -> TemplatePickerViewModel.Item in
            let item = info.element
            let editorController = editorPageAssembly.buildPageModule(browser: nil, data: .init(
                objectId: item.id,
                spaceId: item.spaceId,
                isSupportedForEdit: true,
                isOpenedForPreview: false,
                usecase: .templateEditing
            )).0
            return .template(
                .init(
                    id: info.offset + 1,
                    viewController: GenericUIKitToSwiftUIView(viewController: editorController),
                    viewModel: editorController.viewModel,
                    object: item
                )
            )
        }
        
        items.insert(.blank(0), at: 0)

        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: { _ in })
        let picker = TemplatePickerView(
            viewModel: .init(
                items: items,
                document: document,
                objectService: ServiceLocator.shared.objectActionsService(),
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
