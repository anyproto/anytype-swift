import Combine
import UIKit
import BlocksModels
    
final class FileDownloadingCoordinator {
    
    private let fileLoader = FileLoader()
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
        
}

// MARK: - Entry point

extension FileDownloadingCoordinator {
    
    func downloadFileAt(_ url: URL, withType type: FileContentType) {
        let viewModel = FileDownloadingViewModel(url: url, output: self)
        let view = FileDownloadingView(viewModel: viewModel)
        let popup = AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: false)
        )
        
        viewController?.topPresentedController.present(popup, animated: true)
    }
    
    @available(*, deprecated)
    func saveFile(fileURL: URL, type: FileContentType) {
        let loadData = fileLoader.loadFile(remoteFileURL: fileURL)
        
        let loadingVC = LoadingViewController(
            loadData: loadData,
            informationText: "Loading, please wait".localized,
            loadingCompletion: { [weak self] url in
                self?.showDocumentPickerViewController(url: url)
                AnytypeAnalytics.instance().logDownloadMedia(type: type)
            }
        )
        
        viewController?.topPresentedController.present(loadingVC, animated: true)
    }
    
    private func showDocumentPickerViewController(url: URL) {
        let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        viewController?.topPresentedController.present(controller, animated: true)
    }
    
}

extension FileDownloadingCoordinator: FileDownloadingModuleOutput {
    
    func didDownloadFileTo(_ url: URL) {
        viewController?.topPresentedController.dismiss(animated: true) { [weak self] in
            self?.showDocumentPickerViewController(url: url)
        }
    }
    
    func didAskToClose() {
        viewController?.topPresentedController.dismiss(animated: true)
    }
    
}
