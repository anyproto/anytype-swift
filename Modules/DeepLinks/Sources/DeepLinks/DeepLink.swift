public enum DeepLink: Equatable {
    case createObjectFromWidget
    case showSharingExtension
    case spaceSelection
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
}
