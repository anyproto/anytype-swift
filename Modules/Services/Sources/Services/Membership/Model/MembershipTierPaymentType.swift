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

public struct AppStorePaymentInfo: Hashable, Equatable {
    public let product: Product
    public let fallbackPaymentUrl: URL
}

public enum MembershipTierPaymentType: Hashable, Equatable {
    case appStore(info: AppStorePaymentInfo)
    case external(info: StripePaymentInfo)
}
