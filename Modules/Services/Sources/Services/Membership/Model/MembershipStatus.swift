import ProtobufMessages
import Foundation
import AnytypeCore

public typealias MembershipSubscriptionStatus = Anytype_Model_Membership.Status
public typealias MembershipPaymentMethod = Anytype_Model_Membership.PaymentMethod
public typealias AnyNameExtension = Anytype_Model_NameserviceNameType


public struct AnyName: Equatable {
    public let handle: String
    public let `extension`: AnyNameExtension
    
    public init(handle: String, extension: AnyNameExtension) {
        self.handle = handle
        self.extension = `extension`
    }
}

public struct MembershipStatus: Equatable {
    public let tier: MembershipTier?
    public let status: MembershipSubscriptionStatus
    public let dateEnds: Date
    public let paymentMethod: MembershipPaymentMethod
    public let anyName: AnyName
    
    public init(
        tier: MembershipTier?,
        status: MembershipSubscriptionStatus,
        dateEnds: Date,
        paymentMethod: MembershipPaymentMethod,
        anyName: AnyName
    ) {
        self.tier = tier
        self.status = status
        self.dateEnds = dateEnds
        self.paymentMethod = paymentMethod
        self.anyName = anyName
    }
}
