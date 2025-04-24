import Services
import UIKit
import Combine
import AnytypeCore

final class ImagePreviewMediaHandler: PreviewMediaHandlingProtocol, @unchecked Sendable {
    
    private let fileDetails: FileDetails
    private let imageSource: ImageSource
    private let previewImage: UIImage?
    
    weak var output: (any PreviewMediaHandlingOutput)? = nil
    
    private var cancellables = [AnyCancellable]()
    
    init(fileDetails: FileDetails, previewImage: UIImage?) {
        self.fileDetails = fileDetails
        let imageId = ImageMetadata(id: fileDetails.id, side: .original)
        self.imageSource = .middleware(imageId)
        self.previewImage = previewImage
    }
    
    func startDownloading() {
        if let previewImage {
            updatePreviewItemURL(with: previewImage, data: nil, isPreview: true)
        }

        Task { @MainActor [weak self] in
            
            guard let result = await self?.imageSource.downloadImage(),
                let image = result.image else {
                return
            }

            self?.updatePreviewItemURL(with: image, data: result.data, isPreview: false)
        }
        .cancellable()
        .store(in: &cancellables)
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
