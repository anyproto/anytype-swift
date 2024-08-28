import Foundation
import Services

struct MessageViewData: Identifiable {
    let spaceId: String
    let objectId: String
    let message: ChatMessage
    // TODO: Temporary
    let relativeIndex: Int
    
    var id: String {
        message.id
    }
}
