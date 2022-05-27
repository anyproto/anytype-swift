import Foundation
import UIKit

struct GalleryItemModel {
    let imageSource: ImageSource
    let previewImage: UIImage?
}

struct GalleryViewModel {
    let items: [GalleryItemModel]
    let initialImageDisplayIndex: Int

    init(items: [GalleryItemModel], initialImageDisplayIndex: Int) {
        self.items = items
        self.initialImageDisplayIndex = initialImageDisplayIndex
    }
}
