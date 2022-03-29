import UIKit
import Kingfisher
import AnytypeCore
import Combine

enum ImageSource {
    case image(UIImage)
    case middleware(ImageMetadata)

    var image: Future<UIImage?, Error> {
        Future<UIImage?, Error> { promise in
            switch self {
            case .image(let image):
                promise(.success(image))
            case .middleware(let imageID):
                ImageDownloader.default.downloadImage(from: imageID) { result in
                    switch result {
                    case .failure(let error):
                        promise(.failure(error))
                    case .success(let uiImage):
                        promise(.success(uiImage))
                    }
                }
            }
        }
    }
}

extension ImageDownloader {
    func downloadImage(
        from imageId: ImageMetadata,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        guard let url = imageId.resolvedUrl else {
            anytypeAssertionFailure("fileId has no resolvedUrl", domain: .imageDownloader)
            completion(.failure(KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource)))
            return
        }

        downloadImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                let image = UIImage(data: imageResult.originalData)!
                completion(.success(image))
            case .failure(let error):
                anytypeAssertionFailure(error.localizedDescription, domain: .imageDownloader)
                completion(.failure(error))
            }
        }
    }
}
