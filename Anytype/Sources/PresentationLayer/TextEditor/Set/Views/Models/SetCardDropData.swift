import ProtobufMessages

struct SetCardDropData {
    var initialFromGroupId: String?
    var fromGroupId: String?
    var toGroupId: String?
    var draggingCard: SetContentViewItemConfiguration?
    var droppingCard: SetContentViewItemConfiguration?
    
    mutating func clear() {
        initialFromGroupId = nil
        fromGroupId = nil
        toGroupId = nil
        draggingCard = nil
        droppingCard = nil
    }
}
