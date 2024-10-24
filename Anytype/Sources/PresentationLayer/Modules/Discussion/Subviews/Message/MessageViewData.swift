import Foundation
import Services

struct MessageViewData: Identifiable {
    let objectId: String
    let blockId: String
    // TODO: Temporary
    let relativeIndex: Int
    
    var id: String {
        objectId + blockId
    }
}
