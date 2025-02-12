public enum DeepLink: Equatable {
    case createObjectFromWidget
    case showSharingExtension
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
    case object(objectId: String, spaceId: String, cid: String? = nil, key: String? = nil)
    
    case membership(tierId: Int)
    
    case networkConfig(config: String)
}
