import ProtobufMessages

struct KanbanCardDropData {
    var fromSubId: SubscriptionId?
    var toSubId: SubscriptionId?
    var draggingCard: SetContentViewItemConfiguration?
    var droppingData: SetContentViewItemConfiguration?
}
