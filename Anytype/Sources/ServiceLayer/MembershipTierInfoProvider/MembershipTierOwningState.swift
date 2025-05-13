import StoreKit

enum MembershipExternalPaymentMethod {
    case desktop
    case googlePlay
    case appStore
}

enum MembershipPurchaseType {
    case purchasedInAppStoreWithCurrentAccount
    case purchasedElsewhere(MembershipExternalPaymentMethod)
    case freeTier
}

enum MembershipPurchaseAvailablitiy {
    case appStore(product: Product)
    case external(url: URL)
}

enum MembershipTierOwningState {
    case owned(MembershipPurchaseType)
    case pending
    case unowned(MembershipPurchaseAvailablitiy)
    
    var isOwned: Bool {
        switch self {
        case .owned:
            true
        case .pending, .unowned:
            false
        }
    }
}

extension Optional where Wrapped == MembershipTierOwningState {
    var isOwned: Bool {
        switch self {
        case .none:
            false
        case .some(let wrapped):
            wrapped.isOwned
        }
    }
}
