import Foundation

enum MessageSectionItem: Equatable, Hashable, Identifiable {
    case message(_ data: MessageViewData)
    case unread(id: String, messageId: String, messageOrderId: String)
    case discussionDivider(id: String)
    /// Chat: an agent run's compact line in the gap between messages. Not a message: read
    /// tracking skips it.
    case activityRun(runId: String)
    /// Discussion: activity at the end of a thread.
    case activityThread(rootId: String)

    var id: String {
        switch self {
        case .message(let data):
            data.id
        case .unread(let id, _, _):
            id
        case .discussionDivider(let id):
            id
        case .activityRun(let runId):
            "activity-\(runId)"
        case .activityThread(let rootId):
            "activity-thread-\(rootId)"
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
        case .activityRun, .activityThread:
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
        case .activityRun, .activityThread:
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
        case .discussionDivider, .activityRun, .activityThread:
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
        case .discussionDivider, .activityRun, .activityThread:
            return nil
        }
    }
}
