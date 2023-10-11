import UIKit
import SwiftUI
import Combine
import Services
import AnytypeCore

final class TemplatesCoordinator {
    private weak var rootViewController: UIViewController?
    private let editorPageAssembly: EditorAssembly

    init(
        rootViewController: UIViewController,
        editorPageAssembly: EditorAssembly
    ) {
        self.rootViewController = rootViewController
        self.editorPageAssembly = editorPageAssembly
    }

    @MainActor
    func showTemplatesPicker(
        document: BaseDocumentProtocol,
        availableTemplates: [ObjectDetails]
    ) {
        guard let rootViewController = rootViewController else {
            return
        }

        let items = availableTemplates.enumerated().map { info -> TemplatePickerViewModel.Item in
            let item = info.element
            let data = item.editorScreenData(isOpenedForPreview: true)

            let editorController = editorPageAssembly.buildEditorController(browser: nil, data: data)

            return TemplatePickerViewModel.Item(
                id: info.offset,
                viewController: GenericUIKitToSwiftUIView(viewController: editorController),
                object: item
            )
        }

        let picker = TemplatePickerView(
            viewModel: .init(
                items: items,
                document: document,
                objectService: ServiceLocator.shared.objectActionsService(),
                onSkip: { [weak rootViewController] in
                    rootViewController?.dismiss(animated: true, completion: nil)
                }
            )
        )
        let hostViewController = UIHostingController(rootView: picker)

        hostViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(hostViewController, animated: true, completion: nil)
    }
}
