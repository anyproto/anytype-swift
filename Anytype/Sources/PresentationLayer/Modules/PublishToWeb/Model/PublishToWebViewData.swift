struct PublishToWebViewData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    
    var id: Int { hashValue }
}
