import Combine
import BlocksModels
import AnytypeCore
import UIKit

final class ImagePreviewMedia: NSObject, PreviewRemoteItem {
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    var previewItemTitle: String? { file.metadata.name }
    var previewItemURL: URL?

    let file: BlockFile
    private let imageSource: ImageSource
    private let previewImage: UIImage?
    private let semaphore = DispatchSemaphore(value: 1)
    private var cancellables = [AnyCancellable]()

    init(file: BlockFile, previewImage: UIImage?) {
        self.file = file

        let imageId = ImageMetadata(id: file.metadata.hash, width: .original)
        self.imageSource = .middleware(imageId)
        self.previewImage = previewImage

        super.init()

        if FileManager.default.fileExists(atPath: file.originalPath.relativePath) {
            self.previewItemURL = file.originalPath
        } else {
            startDownloading()
        }
    }

    func startDownloading() {
        if let previewImage = previewImage {
            updatePreviewItemURL(with: previewImage, isPreview: true)
        }

        imageSource.image.sinkWithResult { [weak self] result in
            let _ = result.map { image in
                guard let image = image else {
                    return
                }

                self?.updatePreviewItemURL(with: image, isPreview: false)
            }
        }.store(in: &cancellables)
    }


    func updatePreviewItemURL(with image: UIImage, isPreview: Bool) {
        let data = image.jpegData(compressionQuality: 1)

        guard let data = data else {
            fatalError()
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            self.semaphore.wait()

            do {
                let path = isPreview ? self.file.previewPath : self.file.originalPath


                try data.write(to: path)
                self.previewItemURL = path

                DispatchQueue.main.async {
                    self.didUpdateContentSubject.send(())
                }
            } catch {
                anytypeAssertionFailure("Failed to write into temporary directory", domain: .anytypeImageDownloader)
            }

            self.semaphore.signal()
        }
    }
}
