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
