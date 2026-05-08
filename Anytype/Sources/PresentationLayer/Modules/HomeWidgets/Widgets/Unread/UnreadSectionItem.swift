import Foundation

enum UnreadSectionItem: Identifiable, Equatable {
    case chat(UnreadChatRowData)
    case discussionParent(UnreadDiscussionParentRowData)

    var id: String {
        switch self {
        case .chat(let data):
            return "chat-\(data.id)"
        case .discussionParent(let data):
            return "parent-\(data.id)"
        }
    }

    var sortDate: Date {
        switch self {
        case .chat(let data):
            return data.lastMessageDate ?? .distantPast
        case .discussionParent(let data):
            return data.lastMessageDate ?? .distantPast
        }
    }
}
