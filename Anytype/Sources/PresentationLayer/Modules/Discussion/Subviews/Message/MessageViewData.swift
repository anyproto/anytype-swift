import Foundation
import Services

struct MessageViewData: Identifiable, Equatable {
    let spaceId: String
    let objectId: String
    let chatId: String
    let messageId: String
    
    var id: String {
        messageId
    }
}
