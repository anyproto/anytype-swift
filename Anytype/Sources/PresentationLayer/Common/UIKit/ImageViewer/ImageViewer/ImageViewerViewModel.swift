import UIKit
import Combine

final class ImageViewerViewModel {
    @Published var image: UIImage?

    init(imageSource: ImageSource) {
        self.image = imageSource.uiImage
    }
}

private extension ImageSource {
    var uiImage: UIImage? {
        switch self {
        case .image(let image):
            return image
        case .middleware(let fileId):
            guard let url = fileId.resolvedUrl,
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return nil }

            return image
        }
    }
}
