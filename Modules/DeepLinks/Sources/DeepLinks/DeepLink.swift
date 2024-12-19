public enum DeepLink: Equatable {
    case createObjectFromWidget
    case showSharingExtension
    case spaceSelection
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
    case object(objectId: String, spaceId: String, cid: String?, key: String?)
    
    case spaceShareTip
    case membership(tierId: Int)
    
    case networkConfig(config: String)
}
