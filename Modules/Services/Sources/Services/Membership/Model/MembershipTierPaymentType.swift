import StoreKit
import ProtobufMessages


public typealias MemberhipTierPaymentPeriodType = Anytype_Model_MembershipTierData.PeriodType

public struct StripePaymentInfo: Hashable, Equatable {
    public let periodType: MemberhipTierPaymentPeriodType
    public let periodValue: UInt32
    public let priceInCents: UInt32
    public let paymentUrl: URL
    
    public init(
        periodType: MemberhipTierPaymentPeriodType,
        periodValue: UInt32,
        priceInCents: UInt32,
        paymentUrl: URL
    ) {
        self.periodType = periodType
        self.periodValue = periodValue
        self.priceInCents = priceInCents
        self.paymentUrl = paymentUrl
    }
}

public enum MembershipTierPaymentType: Hashable, Equatable {
    case appStore(product: Product)
    case external(info: StripePaymentInfo)
}
