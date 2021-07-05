final class BookmarkImageLoader {
    let imageProperty: ImageProperty?
    let iconProperty: ImageProperty?

    init(imageHash: String?, iconHash: String?) {
        if let imageHash = imageHash, !imageHash.isEmpty {
            imageProperty = ImageProperty(imageId: imageHash, .init(width: .default))
        } else {
            imageProperty = nil
        }
        
        if let iconHash = iconHash, !iconHash.isEmpty {
            iconProperty = ImageProperty(imageId: iconHash, .init(width: .thumbnail))
        } else {
            iconProperty = nil
        }
    }
}
