import Foundation

enum SharingExtensionTabs: CaseIterable {
    case chat
    case object
}

extension SharingExtensionTabs {
    var title: String {
        switch self {
        case .chat:
            Loc.Sharing.Tab.chat
        case .object:
            Loc.Sharing.Tab.object
        }
    }
}
