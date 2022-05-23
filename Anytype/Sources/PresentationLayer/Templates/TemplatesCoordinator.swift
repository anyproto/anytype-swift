import UIKit
import SwiftUI
import Combine
import BlocksModels
import AnytypeCore

final class TemplatesCoordinator {
    private let rootViewController: UIViewController

    private let searchService: SearchServiceProtocol

    private let keyboardHeightListener: KeyboardHeightListener
    private var keyboardHeightSubscription: AnyCancellable?

    init(
        rootViewController: UIViewController,
        keyboardHeightListener: KeyboardHeightListener,
        searchService: SearchServiceProtocol
    ) {
        self.rootViewController = rootViewController
        self.keyboardHeightListener = keyboardHeightListener
        self.searchService = searchService
    }

    func showTemplatesAvailabilityPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeURL: ObjectTemplateType
    ) {
        guard FeatureFlags.isTemplatesAvailable else { return }

        guard let availableTemplates = searchService.searchTemplates(for: templatesTypeURL) else {
            return
        }
        
        guard availableTemplates.count > 1 else {
            return
        }
        
        let view = TemplateAvailabilityPopupView()

        view.update(with: availableTemplates.count) { [weak rootViewController] in
            rootViewController?.dismiss(animated: true, completion: nil)
        }

        let viewModel = AnytypeAlertViewModel(contentView: view, keyboardListener: keyboardHeightListener)

        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: false, skipThroughGestures: true)
        )

        popup.addPanel(toParent: rootViewController)
    }
}

