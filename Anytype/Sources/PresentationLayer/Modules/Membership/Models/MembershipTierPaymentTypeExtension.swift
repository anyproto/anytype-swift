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
            if periodValue == 1 {
                return Loc.perDay
            } else {
                return Loc.perXDays(periodValue)
            }
        case .weeks:
            if periodValue == 1 {
                return Loc.perWeek
            } else {
                return Loc.perXWeeks(periodValue)
            }
        case .months:
            if periodValue == 1 {
                return Loc.perMonth
            } else {
                return Loc.perXMonths(periodValue)
            }
        case .years:
            if periodValue == 1 {
                return Loc.perYear
            } else {
                return Loc.perXYears(periodValue)
            }
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
            if period.value == 1 {
                return Loc.perDay
            } else {
                return Loc.perXDays(period.value)
            }
        case .week:
            if period.value == 1 {
                return Loc.perWeek
            } else {
                return Loc.perXWeeks(period.value)
            }
        case .month:
            if period.value == 1 {
                return Loc.perMonth
            } else {
                return Loc.perXMonths(period.value)
            }
        case .year:
            if period.value == 1 {
                return Loc.perYear
            } else {
                return Loc.perXYears(period.value)
            }
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
