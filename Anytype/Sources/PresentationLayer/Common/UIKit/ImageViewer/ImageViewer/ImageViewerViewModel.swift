import UIKit
import Combine

final class ImageViewerViewModel {
    @Published var image: UIImage?
    @Published var isLoading: Bool = false

    private var cancellables = [AnyCancellable]()

    init(item: GalleryItemModel) {
        image = item.previewImage

        isLoading = true
        item.imageSource.image.sink { [weak self] _ in
            self?.isLoading = false
        } receiveValue: { [weak self] image in
            self?.image = image
        }.store(in: &cancellables)
    }
}
