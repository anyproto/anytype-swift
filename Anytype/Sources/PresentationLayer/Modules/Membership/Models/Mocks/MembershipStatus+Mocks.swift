import Services


public extension AnyName {
    static var mockEmpty: AnyName {
        AnyName(handle: "", extension: .anyName)
    }
    
    static var mock: AnyName {
        AnyName(handle: "Feyd-Rautha", extension: .anyName)
    }
}


public extension MembershipStatus {
    static var empty: MembershipStatus {
        MembershipStatus(
            tier: nil,
            status: .unknown,
            dateEnds: .distantFuture,
            paymentMethod: .methodStripe,
            anyName: .mock
        )
    }
}
