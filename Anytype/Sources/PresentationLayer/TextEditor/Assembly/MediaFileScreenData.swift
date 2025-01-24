struct MediaFileScreenData: Hashable {
    let item: PreviewRemoteItem
    
    var spaceId: String {
        item.fileDetails.spaceId
    }
}
