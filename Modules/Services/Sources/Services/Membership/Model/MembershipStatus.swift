import ProtobufMessages
import Foundation
import AnytypeCore

public typealias MembershipSubscriptionStatus = Anytype_Model_Membership.Status
public typealias MembershipPaymentMethod = Anytype_Model_Membership.PaymentMethod
public typealias AnyNameExtension = Anytype_Model_NameserviceNameType


public struct AnyName: Equatable, Sendable {
    public let handle: String
    public let `extension`: AnyNameExtension
    
    public init(handle: String, extension: AnyNameExtension) {
        self.handle = handle
        self.extension = `extension`
    }
}

public enum MembershipDateEnds: Equatable, Sendable {
    case never
    case date(Date)
}

public struct MembershipStatus: Equatable, Sendable {
    public let tier: MembershipTier?
    public let status: MembershipSubscriptionStatus
    public let dateEnds: MembershipDateEnds
    public let paymentMethod: MembershipPaymentMethod
    public let anyName: AnyName
    public let email: String
    
    public init(
        tier: MembershipTier?,
        status: MembershipSubscriptionStatus,
        dateEnds: MembershipDateEnds,
        paymentMethod: MembershipPaymentMethod,
        anyName: AnyName,
        email: String
    ) {
        self.tier = tier
        self.status = status
        self.dateEnds = dateEnds
        self.paymentMethod = paymentMethod
        self.anyName = anyName
        self.email = email
    }
}

extension MembershipStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
Tier: \(tier?.name ?? "None")
TierId: \(tier?.type.id ?? 0)
Status: \(status)
PaymentMethod: \(paymentMethod)
AnyName: \(anyName.handle)
Email: \(email)
"""
    }
}
