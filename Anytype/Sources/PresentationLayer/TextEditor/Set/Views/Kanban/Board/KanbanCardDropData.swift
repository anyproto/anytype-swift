import ProtobufMessages

struct KanbanCardDropData {
    var initialFromGroupId: String?
    var fromGroupId: String?
    var toGroupId: String?
    var draggingCard: SetContentViewItemConfiguration?
    var droppingCard: SetContentViewItemConfiguration?
}
