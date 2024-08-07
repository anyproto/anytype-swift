import Combine
import UIKit
import Services
    

@MainActor
final class FileDownloadingCoordinator {
    
    private(set) var type: FileContentType?
    private var spaceId: String = ""
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
        
}

// MARK: - Entry point

extension FileDownloadingCoordinator {
    
    func downloadFileAt(_ url: URL, withType type: FileContentType, spaceId: String) {
        let viewModel = FileDownloadingViewModel(url: url, output: self)
        let view = FileDownloadingView(viewModel: viewModel)
        let popup = AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: false)
        )
        
        self.type = type
        self.spaceId = spaceId
        viewController?.topPresentedController.present(popup, animated: true)
    }
    
}

extension FileDownloadingCoordinator: FileDownloadingModuleOutput {
    
    func didDownloadFileTo(_ url: URL) {
        type.flatMap {
            AnytypeAnalytics.instance().logDownloadMedia(type: $0, spaceId: spaceId)
        }
        viewController?.topPresentedController.dismiss(animated: true) { [weak self] in
            self?.showDocumentPickerViewController(url: url)
        }
    }
    
    func didAskToClose() {
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
    private func showDocumentPickerViewController(url: URL) {
        let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        viewController?.topPresentedController.present(controller, animated: true)
    }
    
}
