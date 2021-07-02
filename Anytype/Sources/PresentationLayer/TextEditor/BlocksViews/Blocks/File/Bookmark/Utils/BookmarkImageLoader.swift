class BookmarkImageLoader {
    /// I want to subscribe on current value subject, lol.
    var imageProperty: ImageProperty?
    var iconProperty: ImageProperty?

    func subscribeImage(_ imageHash: String) {
        guard !imageHash.isEmpty else { return }
        
        imageProperty = ImageProperty(imageId: imageHash, .init(width: .default))
    }

    func subscribeIcon(_ iconHash: String) {
        guard !iconHash.isEmpty else { return }
        
        iconProperty = ImageProperty(imageId: iconHash, .init(width: .thumbnail))
    }
}
