import Foundation

struct MessageSectionData: Identifiable, Equatable, Hashable, ChatCollectionSection {
    var header: String
    var id: Int
    var items: [MessageSectionItem]
}

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
