import StoreKit
import ProtobufMessages


public typealias MemberhipTierPaymentPeriodType = Anytype_Model_MembershipTierData.PeriodType

public struct StripePaymentInfo: Hashable, Equatable {
    public let periodType: MemberhipTierPaymentPeriodType
    public let periodValue: UInt32
    public let priceInCents: UInt32
    
    public var displayPrice: String {
        return "\(priceInCents/100).\(priceInCents%100)"
    }
    
    public init(periodType: MemberhipTierPaymentPeriodType, periodValue: UInt32, priceInCents: UInt32) {
        self.periodType = periodType
        self.periodValue = periodValue
        self.priceInCents = priceInCents
    }
}

public enum MembershipTierPaymentType: Hashable, Equatable {
    case email
    case appStore(product: Product)
    case external(info: StripePaymentInfo)
}
