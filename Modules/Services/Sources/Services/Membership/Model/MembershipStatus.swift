import ProtobufMessages
import Foundation

public typealias MembershipSubscriptionStatus = Anytype_Rpc.Payments.Subscription.SubscriptionStatus
public typealias MembershipPaymentMethod = Anytype_Rpc.Payments.Subscription.PaymentMethod

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
    public let dateEnds: Date
    public let paymentMethod: MembershipPaymentMethod
    
    public init(
        tier: MembershipTier?,
        status: MembershipSubscriptionStatus,
        dateEnds: Date,
        paymentMethod: MembershipPaymentMethod
    ) {
        self.tier = tier
        self.status = status
        self.dateEnds = dateEnds
        self.paymentMethod = paymentMethod
    }
}

