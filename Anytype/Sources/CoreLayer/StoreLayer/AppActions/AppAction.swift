import Foundation

enum AppAction {
    case createObjectFromQuickAction(typeId: String)
    case createObjectFromWidget
    case showSharingExtension
    case spaceSelection
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
}
