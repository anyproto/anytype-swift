import Services
import StoreKit
import AnytypeCore


extension MembershipTierPaymentType {
    var localizedPeriod: String? {
        switch self {
        case .email:
            anytypeAssertionFailure("No localized period for email")
            return nil
        case .appStore(let product):
            return product.localizedPeriod
        case .external(let info):
            return info.localizedPeriod
        }
    }
}

extension StripePaymentInfo {
    var localizedPeriod: String? {
        switch periodType {
        case .days:
            return Loc.perDay(Int(periodValue))
        case .weeks:
            return Loc.perWeek(Int(periodValue))
        case .months:
            return Loc.perMonth(Int(periodValue))
        case .years:
            return Loc.perYear(Int(periodValue))
        case .unlimited:
            return Loc.unlimited
        case .UNRECOGNIZED, .unknown:
            anytypeAssertionFailure("Not supported period \(periodType)")
            return "\(Loc.per) \(periodValue) \(periodType)"
        }
    }
}

extension Product {
    var localizedPeriod: String? {
        guard let period = subscription?.subscriptionPeriod else {
            anytypeAssertionFailure("No subscription for product \(self)")
            return nil
        }
        
        switch period.unit {
        case .day:
            return Loc.perDay(period.value)
        case .week:
            return Loc.perWeek(period.value)
        case .month:
            return Loc.perMonth(period.value)
        case .year:
            return Loc.perYear(period.value)
        @unknown default:
            anytypeAssertionFailure("Not supported period \(period.unit)")
            return "\(Loc.per) \(period.value) \(period.unit)"
        }
    }
}

// MARK: - Mocks
public extension MembershipTierPaymentType {
    static var mockExternal: MembershipTierPaymentType {
        .external(info: .mockInfo)
    }
}

extension StripePaymentInfo {
    static var mockInfo: StripePaymentInfo {
        StripePaymentInfo(periodType: .years, periodValue: 1, priceInCents: 10000)
    }
}
