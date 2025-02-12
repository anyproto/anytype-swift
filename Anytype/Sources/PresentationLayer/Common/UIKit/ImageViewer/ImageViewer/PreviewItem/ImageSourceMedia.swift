import Combine
import Services
import AnytypeCore
import UIKit

final class ImagePreviewMedia: NSObject, PreviewRemoteItem {
    
    // MARK: - PreviewRemoteItem
    let id: String
    let fileDetails: FileDetails
    let didUpdateContentSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - QLPreviewItem
    var previewItemTitle: String? { fileDetails.fileName }
    var previewItemURL: URL?

    private let imageSource: ImageSource
    private let previewImage: UIImage?
    private var cancellables = [AnyCancellable]()

    init(previewImage: UIImage? = nil, fileDetails: FileDetails) {
        self.id = fileDetails.id
        self.previewImage = previewImage
        self.fileDetails = fileDetails

        let imageId = ImageMetadata(id: fileDetails.id, width: .original)
        self.imageSource = .middleware(imageId)

        super.init()

        let path = FileManager.originalPath(objectId: fileDetails.id, fileName: fileDetails.fileName)
        if FileManager.default.fileExists(atPath: path.relativePath) {
            self.previewItemURL = path
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
        let data = data.isNil ? image.pngData() : data
        guard let data else { return }

        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            do {
                let path = isPreview ?
                FileManager.previewPath(objectId: fileDetails.id, fileName: fileDetails.fileName) :
                FileManager.originalPath(objectId: fileDetails.id, fileName: fileDetails.fileName)

                try FileManager.default.createDirectory(
                    at: path.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                
                try data.write(to: path, options: [.atomic])
                previewItemURL = path
                didUpdateContentSubject.send(())
            } catch {
                anytypeAssertionFailure("Failed to write image into temporary directory")
            }
        }
    }
}
