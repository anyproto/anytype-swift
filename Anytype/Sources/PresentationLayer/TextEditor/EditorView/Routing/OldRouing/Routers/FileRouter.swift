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
    
    func handle(action: BlockUserAction.FileAction) {
        switch action {
        case let .shouldShowFilePicker(model):
            let vc = CommonViews.Pickers.File.Picker(model)
            viewController?.present(vc, animated: true, completion: nil)
        case let .shouldShowImagePicker(model):
            let vc = MediaPicker(viewModel: model)
            viewController?.present(vc, animated: true, completion: nil)
        case let .shouldSaveFile(fileURL):
            saveFile(fileURL: fileURL)
        default: return
        }
    }
    
    private func saveFile(fileURL: URL) {
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
        viewController?.present(loadingVC, animated: true, completion: nil)
    }
}
