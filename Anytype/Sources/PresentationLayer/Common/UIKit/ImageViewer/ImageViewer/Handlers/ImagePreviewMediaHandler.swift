import Services
import UIKit
import Combine
import AnytypeCore

final class ImagePreviewMediaHandler: PreviewMediaHandlingProtocol {
    
    private let fileDetails: FileDetails
    private let imageSource: ImageSource
    private let previewImage: UIImage?
    
    weak var output: (any PreviewMediaHandlingOutput)? = nil
    
    private var cancellables = [AnyCancellable]()
    
    init(fileDetails: FileDetails, previewImage: UIImage?) {
        self.fileDetails = fileDetails
        // Download 1920 image for fullscreen for demo (640 * 3 (screen scale))
        let side = FeatureFlags.download1920ImageForFullscreen ? ImageSide.width(640) : ImageSide.original
        let imageId = ImageMetadata(id: fileDetails.id, side: side)
        self.imageSource = .middleware(imageId)
        self.previewImage = previewImage
    }
    
    func startDownloading() {
        if let previewImage {
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
                output?.onUpdate(path: path)
            } catch {
                anytypeAssertionFailure("Failed to write image into temporary directory")
            }
        }
    }
}
