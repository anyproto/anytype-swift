import Combine
import UIKit
import Amplitude

    
final class FileRouter {
    
    private let fileLoader: FileLoader
    private weak var viewController: UIViewController?
    
    init(fileLoader: FileLoader, viewController: UIViewController?) {
        self.fileLoader = fileLoader
        self.viewController = viewController
    }
        
    func saveFile(fileURL: URL) {
        let loadData = fileLoader.loadFile(remoteFileURL: fileURL)
        
        let loadingVC = LoadingViewController(
            loadData: loadData,
            informationText: NSLocalizedString("Loading, please wait", comment: ""),
            loadingCompletion: { [weak self] url in
                let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
                self?.viewController?.present(controller, animated: true, completion: nil)

                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.downloadFile)
            }
        )
        
        DispatchQueue.main.async {
            self.viewController?.present(loadingVC, animated: true, completion: nil)
        }
    }
}
