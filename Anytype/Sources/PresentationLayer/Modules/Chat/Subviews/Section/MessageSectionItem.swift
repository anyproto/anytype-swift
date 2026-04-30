import Foundation

enum MessageSectionItem: Equatable, Hashable, Identifiable {
    case message(_ data: MessageViewData)
    case unread(id: String, messageId: String, messageOrderId: String)
    case discussionDivider(id: String)

    var id: String {
        switch self {
        case .message(let data):
            data.id
        case .unread(let id, _, _):
            id
        case .discussionDivider(let id):
            id
        }
    }
}

extension MessageSectionItem {
    var messageId: String {
        switch self {
        case .message(let data):
            return data.message.id
        case .unread(_, let messageId, _):
            return messageId
        case .discussionDivider(let id):
            return id
        }
    }

    var messageOrderId: String {
        switch self {
        case .message(let data):
            return data.message.orderID
        case .unread(_, _, let messageOrderId):
            return messageOrderId
        case .discussionDivider(let id):
            return id
        }
    }

    /// Real message id for read-tracking; nil for non-message cells (dividers).
    var trackedMessageId: String? {
        switch self {
        case .message(let data):
            return data.message.id
        case .unread(_, let messageId, _):
            return messageId
        case .discussionDivider:
            return nil
        }
    }

    /// Real message orderID for read-tracking; nil for non-message cells (dividers).
    var trackedOrderId: String? {
        switch self {
        case .message(let data):
            return data.message.orderID
        case .unread(_, _, let messageOrderId):
            return messageOrderId
        case .discussionDivider:
            return nil
        }
    }
}
