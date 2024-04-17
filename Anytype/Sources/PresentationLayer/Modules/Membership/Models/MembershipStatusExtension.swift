import Services
import Foundation


public extension MembershipStatus {
    static var empty: MembershipStatus {
        return MembershipStatus(
            tier: nil,
            status: .unknown,
            dateEnds: .distantFuture,
            paymentMethod: .methodStripe,
            anyName: ""
        )
    }
    
    var formattedDateEnds: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
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
