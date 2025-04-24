import Foundation
import DeepLinks

enum AppAction: Sendable {
    case createObjectFromQuickAction(typeId: String)
    case startObject(objectId: String, spaceId: String)
    case deepLink(_ deepLink: DeepLink, _ source: DeepLinkSource)
}
