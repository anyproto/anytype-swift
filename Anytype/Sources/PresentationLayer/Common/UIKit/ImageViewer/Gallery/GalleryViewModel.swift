import Foundation

struct GalleryViewModel {
    let imageSources: [ImageSource]
    let initialImageDisplayIndex: Int

    init(imageSources: [ImageSource], initialImageDisplayIndex: Int) {
        self.imageSources = imageSources
        self.initialImageDisplayIndex = initialImageDisplayIndex
    }
}
