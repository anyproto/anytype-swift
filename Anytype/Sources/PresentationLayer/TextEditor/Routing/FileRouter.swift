import Combine
import UIKit
import BlocksModels
    
final class FileRouter {
    
    private let fileLoader: FileLoader
    private weak var viewController: UIViewController?
    
    init(fileLoader: FileLoader, viewController: UIViewController?) {
        self.fileLoader = fileLoader
        self.viewController = viewController
    }
        
    func saveFile(fileURL: URL, type: FileContentType) {
        let loadData = fileLoader.loadFile(remoteFileURL: fileURL)
        
        let loadingVC = LoadingViewController(
            loadData: loadData,
            informationText: "Loading, please wait".localized,
            loadingCompletion: { [weak self] url in
                let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
                self?.viewController?.present(controller, animated: true, completion: nil)
                AnytypeAnalytics.instance().logDownloadMedia(type: type)
            }
        )
        
        DispatchQueue.main.async {
            self.viewController?.present(loadingVC, animated: true, completion: nil)
        }
    }
}
