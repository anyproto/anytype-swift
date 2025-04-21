import UIKit
import AnytypeCore
@preconcurrency import Combine

struct ImageSourceResult: Sendable {
    let image: UIImage?
    let data: Data?
}

enum ImageSource: @unchecked Sendable {
    case image(UIImage)
    case middleware(ImageMetadata)
}

extension ImageSource {
    func downloadImage() async -> ImageSourceResult {
        switch self {
        case .image(let image):
            return ImageSourceResult(image: image, data: nil)
        case .middleware(let imageID):
            guard let url = imageID.contentUrl else {
                return ImageSourceResult(image: nil, data: nil)
            }

            let result = await AnytypeImageDownloader.retrieveImage(
                with: url,
                options: [.memoryCacheExpiration(.expired), .diskCacheExpiration(.expired)]
            )
            
            return ImageSourceResult(image: result?.image, data: result?.data())
        }
    }
}
