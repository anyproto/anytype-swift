import Foundation

enum AppAction {
    case createObject(typeId: String)
    case createDefaultObject
    case showSharingExtension
    case spaceSelection
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
}
