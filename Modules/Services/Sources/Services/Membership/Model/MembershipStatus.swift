import ProtobufMessages
import Foundation
import AnytypeCore

public typealias MembershipSubscriptionStatus = Anytype_Model_Membership.Status
public typealias MembershipPaymentMethod = Anytype_Model_Membership.PaymentMethod


public struct MembershipStatus: Equatable {
    public let tier: MembershipTier?
    public let status: MembershipSubscriptionStatus
    public let dateEnds: Date
    public let paymentMethod: MembershipPaymentMethod
    public let anyName: String
    
    public init(
        tier: MembershipTier?,
        status: MembershipSubscriptionStatus,
        dateEnds: Date,
        paymentMethod: MembershipPaymentMethod,
        anyName: String
    ) {
        self.tier = tier
        self.status = status
        self.dateEnds = dateEnds
        self.paymentMethod = paymentMethod
        self.anyName = anyName
    }
}
