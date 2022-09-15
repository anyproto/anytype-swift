import Foundation

struct SubscriptionId: Hashable {
    let value: String
}

extension SubscriptionId {
    
    static var set = SubscriptionId(value: "SubscriptionId.Set")
    static var relation = SubscriptionId(value: "SubscriptionId.Relation")
    static var objectType = SubscriptionId(value: "SubscriptionId.ObjectType")
}
