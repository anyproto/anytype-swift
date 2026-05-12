public enum DeepLink: Equatable, Sendable {
    case createObjectFromWidget
    case showSharingExtension
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
    case object(objectId: String, spaceId: String, cid: String? = nil, key: String? = nil)
    case chatMessage(chatObjectId: String, spaceId: String, messageId: String)
    case hi(identity: String, key: String)

    case membership(tierId: Int)

    case networkConfig(config: String)
}
