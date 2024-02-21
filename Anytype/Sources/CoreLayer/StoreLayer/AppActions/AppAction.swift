import Foundation
import DeepLinks

enum AppAction {
    case createObjectFromQuickAction(typeId: String)
    case deepLink(_ deepLink: DeepLink)
}
