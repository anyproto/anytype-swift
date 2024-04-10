import UIKit
import AnytypeCore
import Combine

enum ImageSource {
    case image(UIImage)
    case middleware(ImageMetadata)

    var image: Future<(UIImage?, Data?), Error> {
        Future<(UIImage?, Data?), Error> { promise in
            switch self {
            case .image(let image):
                promise(.success((image, nil)))
            case .middleware(let imageID):
                guard let url = imageID.contentUrl else {
                    promise(.success((nil, nil)))
                    return
                }

                AnytypeImageDownloader.retrieveImage(
                    with: url, options: [.memoryCacheExpiration(.expired), .diskCacheExpiration(.expired)]
                ) { image, data in
                    promise(.success((image, data)))
                }
            }
        }
    }
}
