import Foundation

enum MessageSectionItem: Equatable, Hashable, Identifiable {
    case message(_ data: MessageViewData)
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
