import Combine
import UIKit


class FileBlocksViewsRouter: DocumentViewBaseCompoundRouter {
    override func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? {
        switch action {
        case .file: return self.router(of: FileRouter.self)
        default: return nil
        }
    }
    override func defaultRouters() -> [DocumentViewBaseRouter] {
        [FileRouter(fileLoader: FileLoader())]
    }
}


// MARK: FileBlocksViewsRouter / ImageRouter
extension FileBlocksViewsRouter {
    typealias BaseRouter = DocumentViewBaseRouter
    
    final class FileRouter: BaseRouter {
        
        private let fileLoader: FileLoader
        private var subscription: AnyCancellable?
        
        init(fileLoader: FileLoader) {
            self.fileLoader = fileLoader
        }
        
        private func handle(action: BlocksViews.UserAction.File.FileAction) {
            switch action {
            case let .shouldShowFilePicker(model):
                self.send(event: .general(.show(CommonViews.Pickers.File.Picker.init(model.model))))
            case let .shouldShowImagePicker(model):
                self.send(event: .general(.show(MediaPicker(viewModel: model.model))))
            case let .shouldSaveFile(model):
                self.saveFile(model: model)
            default: return
            }
        }
        
        private func saveFile(model: BlocksViews.UserAction.File.FileAction.ShouldSaveFile) {
            let value = self.fileLoader.loadFile(remoteFileURL: model.fileURL)
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
                            self?.send(event: .general(.show(controller)))
                        }
                      })
            self.send(event: .general(.show(loadingVC)))
        }
        
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .file(value): handle(action: value)
            default: return
            }
        }
    }
}
