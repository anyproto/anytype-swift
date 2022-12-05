import UIKit
import SwiftUI
import Combine
import BlocksModels
import AnytypeCore

final class TemplatesCoordinator {
    private enum Constants {
        static let minimumTemplatesAvailableToPick = 2
    }

    private weak var rootViewController: UIViewController?

    private let searchService: SearchServiceProtocol
    private let editorPageAssembly: EditorAssembly
    private let objectsService: ObjectActionsServiceProtocol

    private let keyboardHeightListener: KeyboardHeightListener
    private var keyboardHeightSubscription: AnyCancellable?
    private weak var currentPopup: AnytypePopup?

    init(
        rootViewController: UIViewController,
        keyboardHeightListener: KeyboardHeightListener,
        searchService: SearchServiceProtocol,
        objectsService: ObjectActionsServiceProtocol,
        editorPageAssembly: EditorAssembly
    ) {
        self.rootViewController = rootViewController
        self.keyboardHeightListener = keyboardHeightListener
        self.searchService = searchService
        self.objectsService = objectsService
        self.editorPageAssembly = editorPageAssembly
    }

    func showTemplatesPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    ) {
        let isSelectTemplate = document.details?.isSelectTemplate ?? false
        guard isSelectTemplate, let availableTemplates = searchService.searchTemplates(for: templatesTypeId) else {
            return
        }
        
        currentPopup?.removePanelFromParent(animated: false, completion: nil)
        
        guard availableTemplates.count >= Constants.minimumTemplatesAvailableToPick else {
            return
        }

        onShow?()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.showTemplateAvailablitityPopup(
                availableTemplates: availableTemplates,
                document: document
            )
        }
    }
    
    func showTemplatesPopupWithTypeCheckIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    ) {
        let needShowTypeMenu = document.details?.isSelectType ?? false &&
        !document.objectRestrictions.objectRestriction.contains(.typechange)
        guard !needShowTypeMenu else {
            return
        }
        showTemplatesPopupIfNeeded(
            document: document,
            templatesTypeId: templatesTypeId,
            onShow: onShow
        )
    }

    private func showTemplateAvailablitityPopup(
        availableTemplates: [ObjectDetails],
        document: BaseDocumentProtocol
    ) {
        guard let rootViewController = rootViewController else {
            return
        }

        let view = TemplateAvailabilityPopupView()
        let viewModel = AnytypeAlertViewModel(contentView: view, keyboardListener: keyboardHeightListener)

        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: false, skipThroughGestures: true),
            onDismiss: { [weak self] in
                self?.resetTemplatesFlag(for: document)
            }
        )

        currentPopup = popup

        view.update(with: availableTemplates.count) { [weak self, weak popup] in
            popup?.removePanelFromParent(animated: true) {
                self?.showTemplatesPicker(document: document, availableTemplates: availableTemplates)
            }
        }

        popup.addPanel(toParent: rootViewController, animated: true)
    }

    private func showTemplatesPicker(
        document: BaseDocumentProtocol,
        availableTemplates: [ObjectDetails]
    ) {
        guard let rootViewController = rootViewController else {
            return
        }

        let items = availableTemplates.enumerated().map { info -> TemplatePickerViewModel.Item in
            let item = info.element
            let data = EditorScreenData(pageId: item.id, type: .page, isOpenedForPreview: true)

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
    
    private func resetTemplatesFlag(for document: BaseDocumentProtocol) {
        guard let details = document.details else { return }
        
        Task {
            try await objectsService.setInternalFlags(
                contextId: details.id,
                internalFlags: details.internalFlagsWithoutTemplates
            )
        }
    }
}
