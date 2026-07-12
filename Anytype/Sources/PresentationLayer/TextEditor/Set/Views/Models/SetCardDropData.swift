import Foundation
import ProtobufMessages

struct SetCardDropData {
    var dragSessionId: UUID?
    var initialFromGroupId: String?
    var fromGroupId: String?
    var toGroupId: String?
    var draggingCard: SetContentViewItemConfiguration?
    var droppingCard: SetContentViewItemConfiguration?

    mutating func clear() {
        dragSessionId = nil
        initialFromGroupId = nil
        fromGroupId = nil
        toGroupId = nil
        draggingCard = nil
        droppingCard = nil
    }
}
