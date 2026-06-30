public enum DeepLink: Equatable, Sendable {
    case createObjectFromWidget
    case showSharingExtension
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
    case object(objectId: String, spaceId: String, cid: String? = nil, key: String? = nil)
    case chatMessage(chatObjectId: String, spaceId: String, messageId: String)
    case hi(identity: String, key: String)

    case membership(tierId: Int?, code: String?)

    case networkConfig(config: String)
}

public extension DeepLink {
    // Space id the link navigates into, if the link targets a specific space
    var spaceId: String? {
        switch self {
        case let .object(_, spaceId, _, _):
            return spaceId
        case let .chatMessage(_, spaceId, _):
            return spaceId
        case .createObjectFromWidget, .showSharingExtension, .galleryImport, .invite, .hi, .membership, .networkConfig:
            return nil
        }
    }
}
