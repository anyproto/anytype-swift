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

extension MembershipStatus {
    static var empty: MembershipStatus {
        MembershipStatus(
            tier: nil,
            status: .unknown,
            dateEnds: .never,
            paymentMethod: .methodStripe,
            anyName: .mockEmpty,
            email: ""
        )
    }
    
    var formattedDateEnds: String {
        switch dateEnds {
        case .never:
            return Loc.forever
        case .date(let date):
            let dateFormatter = DateFormatter.defaultDateFormatter
            return dateFormatter.string(from: date)
        }
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
    
    var decoration: SettingsSectionItemView.Decoration {
        guard let tier else { return .button(text: Loc.join) }
        
        switch tier.type {
        case .legacyExplorer, .starter:
            return .button(text: Loc.join)
        case .explorer, .builder, .coCreator, .anyTeam, .custom:
            return .arrow (text: tier.name)
        }
    }
}
