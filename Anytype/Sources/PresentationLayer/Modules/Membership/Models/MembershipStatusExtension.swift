import Services
import Foundation

extension AnyNameExtension: @retroactive CustomStringConvertible  {
    public var description: String {
        switch self {
        case .anyName:
            ".any"
        case .UNRECOGNIZED:
            ""
        }
    }
}

public extension MembershipStatus {
    static var empty: MembershipStatus {
        MembershipStatus(
            tier: nil,
            status: .unknown,
            dateEnds: .distantFuture,
            paymentMethod: .methodStripe,
            anyName: .mockEmpty,
            email: ""
        )
    }
    
    var formattedDateEnds: String {
        let dateFormatter = DateFormatter.defaultDateFormatter
        return dateFormatter.string(from: dateEnds)
    }
    
    var localizablePaymentMethod: String? {
        switch paymentMethod {
        case .methodStripe:
            Loc.Membership.Payment.card
        case .methodCrypto:
            Loc.Membership.Payment.crypto
        case .methodInappApple:
            Loc.Membership.Payment.appleSubscription
        case .methodInappGoogle:
            Loc.Membership.Payment.googleSubscription
        case .UNRECOGNIZED, .methodNone:
            nil
        }
    }
}
