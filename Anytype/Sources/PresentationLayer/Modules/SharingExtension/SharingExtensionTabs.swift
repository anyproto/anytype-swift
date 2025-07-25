import Foundation

enum SharingExtensionTabs: CaseIterable {
    case chat
    case object
}

extension SharingExtensionTabs {
    var title: String {
        switch self {
        case .chat:
            Loc.Shating.Tab.chat
        case .object:
            Loc.Shating.Tab.object
        }
    }
}
