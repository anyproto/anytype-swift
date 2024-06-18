import Combine
import Services
import AnytypeCore
import UIKit

final class ImagePreviewMedia: NSObject, PreviewRemoteItem {
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    var previewItemTitle: String? { fileDetails.fileName }
    var previewItemURL: URL?

    let file: BlockFile
    let fileDetails: FileDetails
    private let blockId: String
    private let imageSource: ImageSource
    private let previewImage: UIImage?
    private let semaphore = DispatchSemaphore(value: 1)
    private var cancellables = [AnyCancellable]()

    init(file: BlockFile, blockId: String, previewImage: UIImage?, fileDetails: FileDetails) {
        self.file = file
        self.fileDetails = fileDetails

        let imageId = ImageMetadata(id: file.metadata.targetObjectId, width: .original)
        self.imageSource = .middleware(imageId)
        self.previewImage = previewImage
        self.blockId = blockId

        super.init()

        if FileManager.default.fileExists(atPath: file.originalPath(blockId: blockId, fileName: fileDetails.fileName).relativePath) {
            self.previewItemURL = file.originalPath(blockId: blockId, fileName: fileDetails.fileName)
        } else {
            startDownloading()
        }
    }

    func startDownloading() {
        if let previewImage = previewImage {
            updatePreviewItemURL(with: previewImage, data: nil, isPreview: true)
        }

        imageSource.image.sinkWithResult { [weak self] result in
            let _ = result.map { result in
                guard let image = result.0 else {
                    return
                }

                self?.updatePreviewItemURL(with: image, data: result.1, isPreview: false)
            }
        }.store(in: &cancellables)
    }


    func updatePreviewItemURL(with image: UIImage, data: Data?, isPreview: Bool) {
        let data = {
            guard let data = data else {
                return image.pngData()
            }
            
            return data
        }()
        
        guard let data = data else { return }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            self.semaphore.wait()

            do {
                let path = isPreview 
                    ? self.file.previewPath(blockId: self.blockId, fileName: fileDetails.fileName)
                    : self.file.originalPath(blockId: self.blockId, fileName: fileDetails.fileName)

                try FileManager.default.createDirectory(
                    at: path.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try data.write(to: path)
                self.previewItemURL = path

                DispatchQueue.main.async {
                    self.didUpdateContentSubject.send(())
                }
            } catch {
                anytypeAssertionFailure("Failed to write into temporary directory")
            }

            self.semaphore.signal()
        }
    }
}
