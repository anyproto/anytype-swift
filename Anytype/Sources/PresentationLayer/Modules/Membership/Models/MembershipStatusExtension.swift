import Services
import Foundation


public extension MembershipStatus {
    static var empty: MembershipStatus {
        return MembershipStatus(
            tier: nil,
            status: .unknown,
            dateEnds: .distantFuture,
            paymentMethod: .methodCard,
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
        case .methodCard:
            Loc.Membership.Payment.card
        case .methodCrypto:
            Loc.Membership.Payment.crypto
        case .methodApplePay:
            Loc.Membership.Payment.applePay
        case .methodGooglePay:
            Loc.Membership.Payment.googlePay
        case .methodAppleInapp:
            Loc.Membership.Payment.appleSubscription
        case .methodGoogleInapp:
            Loc.Membership.Payment.googleSubscription
        case .UNRECOGNIZED:
            nil
        }
    }
}
