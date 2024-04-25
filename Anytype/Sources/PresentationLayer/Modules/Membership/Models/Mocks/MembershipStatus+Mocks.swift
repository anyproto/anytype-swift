import Services
import ProtobufMessages


public extension AnyName {
    static var mockEmpty: AnyName {
        AnyName(handle: "", extension: .anyName)
    }
    
    static var mock: AnyName {
        AnyName(handle: "Feyd-Rautha", extension: .anyName)
    }
}


public extension MembershipStatus {    
    static func mock(
        tier: MembershipTier?,
        status: MembershipSubscriptionStatus = .active,
        paymentMethod: MembershipPaymentMethod = .methodInappApple,
        anyName: AnyName = .mockEmpty
    ) -> MembershipStatus {
        MembershipStatus(
            tier: tier,
            status: status,
            dateEnds: .tomorrow,
            paymentMethod: paymentMethod,
            anyName: anyName
        )
    }
}
