import Foundation

enum SharingExtensionTabs: CaseIterable {
    case chat
    case data
}

extension SharingExtensionTabs {
    var title: String {
        switch self {
        case .chat:
            "Send to chat"
        case .data:
            "Save as object"
        }
    }
}
