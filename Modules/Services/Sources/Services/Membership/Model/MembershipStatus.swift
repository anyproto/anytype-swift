import ProtobufMessages
import Foundation

public typealias MembershipSubscriptionStatus = Anytype_Model_Membership.Status
public typealias MembershipPaymentMethod = Anytype_Model_Membership.PaymentMethod


public struct MembershipStatus: Equatable {
    public let tierId: MembershipTierId?
    public let status: MembershipSubscriptionStatus
    public let dateEnds: Date
    public let paymentMethod: MembershipPaymentMethod
    public let anyName: String
    
    public init(
        tierId: MembershipTierId?,
        status: MembershipSubscriptionStatus,
        dateEnds: Date,
        paymentMethod: MembershipPaymentMethod,
        anyName: String
    ) {
        self.tierId = tierId
        self.status = status
        self.dateEnds = dateEnds
        self.paymentMethod = paymentMethod
        self.anyName = anyName
    }
}


// MARK: - Middleware model mapping

public extension Anytype_Model_Membership {
    func asModel() -> MembershipStatus {
        MembershipStatus(
            tierId: MembershipTierId(intId: tier),
            status: status,
            dateEnds: Date(timeIntervalSince1970: TimeInterval(dateEnds)),
            paymentMethod: paymentMethod,
            anyName: requestedAnyName
        )
    }
}
