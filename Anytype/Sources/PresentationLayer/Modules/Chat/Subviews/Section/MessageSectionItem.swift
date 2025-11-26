import Foundation

enum MessageSectionItem: Equatable, Hashable, Identifiable {
    case message(_ data: MessageViewData)
    case unread(id: String, messageId: String, messageOrderId: String)
    
    var id: String {
        switch self {
        case .message(let data):
            data.id
        case .unread(let id, _, _):
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
        }
    }
    
    var messageOrderId: String {
        switch self {
        case .message(let data):
            return data.message.orderID
        case .unread(_, _, let messageOrderId):
            return messageOrderId
        }
    }
}
