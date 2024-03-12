import ProtobufMessages


public typealias MembershipSubscriptionStatus = Anytype_Rpc.Payments.Subscription.SubscriptionStatus

public enum MembershipTier: Hashable, Identifiable {
    case explorer
    case builder
    case coCreator
    
    case custom(id: Int32)
    
    public var id: Self {
        return self
    }
}

public struct MembershipStatus: Equatable {
    public let tier: MembershipTier?
    public let status: MembershipSubscriptionStatus
    
    public init(tier: MembershipTier?, status: MembershipSubscriptionStatus) {
        self.tier = tier
        self.status = status
    }
}

public extension MembershipStatus {
    static var empty: MembershipStatus {
        MembershipStatus(
            tier: nil,
            status: .statusUnknown
        )
    }
}
