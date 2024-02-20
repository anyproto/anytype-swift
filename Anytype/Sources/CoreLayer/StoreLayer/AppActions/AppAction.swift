import Foundation
import DeepLinks

enum AppAction {
    case createObject(typeId: String)
    case deepLink(_ deepLink: DeepLink)
}
