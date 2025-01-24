struct MediaFileScreenData: Hashable {
    let items: [PreviewRemoteItem]
    let startAtIndex: Int
    
    init(items: [PreviewRemoteItem], startAtIndex: Int = 0) {
        self.items = items
        self.startAtIndex = startAtIndex
    }
    
    var spaceId: String {
        items.first?.fileDetails.spaceId ?? ""
    }
}
