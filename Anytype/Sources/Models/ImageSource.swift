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
                guard let url = imageID.contentUrl else {
                    promise(.success(nil))
                    return
                }

                AnytypeImageDownloader.retrieveImage(with: url) { image in
                    promise(.success(image))
                }
            }
        }
    }
}
