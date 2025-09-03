import Foundation

enum MessageSectionItem: Equatable, Hashable, Identifiable {
    case message(_ data: MessageUIViewData)
    case unread(_ id: String)
    
    var id: String {
        switch self {
        case .message(let data):
            data.id
        case .unread(let id):
            id
        }
    }
}

extension MessageSectionItem {
    var messageData: MessageUIViewData? {
        switch self {
        case .message(let data):
            return data
        case .unread:
            return nil
        }
    }
}
