import Combine
import UIKit
    
final class FileRouter {
    
    private let fileLoader: FileLoader
    private var subscription: AnyCancellable?
    private weak var viewController: UIViewController?
    
    init(fileLoader: FileLoader, viewController: UIViewController?) {
        self.fileLoader = fileLoader
        self.viewController = viewController
    }
        
    func saveFile(fileURL: URL) {
        let value = self.fileLoader.loadFile(remoteFileURL: fileURL)
        let informationText = NSLocalizedString("Loading, please wait", comment: "")
        let cancelHandler: () -> Void = { value.task.cancel() }
        let progressValuePublisher = value.progressPublisher.map { $0.percentComplete }
            .eraseToAnyPublisher()
        let loadingVC = LoadingViewController(progressPublisher: progressValuePublisher,
                                              informationText: informationText,
                                              cancelHandler: cancelHandler)
        let resultPublisher = value.progressPublisher.map { $0.fileURL }
            .safelyUnwrapOptionals()
            .eraseToAnyPublisher()
        self.subscription = resultPublisher
            .receiveOnMain()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { url in
                    loadingVC.dismiss(animated: true) { [weak self] in
                        let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
                        self?.viewController?.present(controller, animated: true, completion: nil)
                    }
                  })
        
        DispatchQueue.main.async {
            self.viewController?.present(loadingVC, animated: true, completion: nil)
        }
    }
}
