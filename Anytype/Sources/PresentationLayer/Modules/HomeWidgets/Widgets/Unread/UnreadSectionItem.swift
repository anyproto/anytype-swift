import Foundation

enum UnreadSectionItem: Identifiable, Equatable {
    case chat(UnreadChatWidgetData, lastMessageDate: Date?)
    case discussionParent(UnreadDiscussionParentWidgetData, lastMessageDate: Date?)

    var id: String {
        switch self {
        case .chat(let data, _):
            return "chat-\(data.id)"
        case .discussionParent(let data, _):
            return "parent-\(data.id)"
        }
    }

    var sortDate: Date {
        switch self {
        case .chat(_, let date), .discussionParent(_, let date):
            return date ?? .distantPast
        }
    }
}
