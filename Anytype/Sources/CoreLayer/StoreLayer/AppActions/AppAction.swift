import Foundation

enum AppAction {
    case createObject
    case showSharingExtension
    case spaceSelection
    case galleryImport(type: String, source: String)
    case invite(cid: String, key: String)
}
