import Services
import AnytypeCore
import StoreKit


protocol MembershipMetadataProviderProtocol: Sendable {
    func owningState(tier: MembershipTier) async -> MembershipTierOwningState
    
    func purchaseType(status: MembershipStatus) async -> MembershipPurchaseType
    func purchaseAvailablitiy(tier: MembershipTier, status: MembershipStatus) async -> MembershipPurchaseAvailablitiy
}

final class MembershipMetadataProvider: MembershipMetadataProviderProtocol, Sendable {
    private let storage: any MembershipStatusStorageProtocol = Container.shared.membershipStatusStorage()
    private let storeKitService: any StoreKitServiceProtocol = Container.shared.storeKitService()
    
    func owningState(tier: MembershipTier) async -> MembershipTierOwningState {
        let status = await storage.currentStatus
        
        if status.tier?.type == tier.type {
            if status.status == .active {
                let purchaseType = await purchaseType(status: status)
                return .owned(purchaseType)
            } else {
                return .pending
            }
        }
        
        let purchaseAvailablitiy = await purchaseAvailablitiy(tier: tier, status: status)
        return .unowned(purchaseAvailablitiy)
    }
    
                
    func purchaseType(status: MembershipStatus) async -> MembershipPurchaseType {
        return switch status.paymentMethod {
        case .methodStripe, .methodCrypto, .UNRECOGNIZED, .methodNone:
                .purchasedElsewhere(.desktop)
        case .methodInappGoogle:
                .purchasedElsewhere(.googlePlay)
        case .methodInappApple:
            await applePurchaseType(status: status)
        }
    }
        
    func applePurchaseType(status: MembershipStatus) async -> MembershipPurchaseType {
        switch status.tier?.paymentType {
        case .appStore(let info):
            guard let isPurchased = try? await storeKitService.isPurchased(product: info.product) else {
                return .purchasedElsewhere(.appStore)
            }
            
            return isPurchased ? .purchasedInAppStoreWithCurrentAccount : .purchasedElsewhere(.appStore)
        case .external, nil:
            anytypeAssertionFailure(
                "Wrong payment type for appstore payment",
                info: ["PaymentType": String(reflecting: status.tier?.paymentType)]
            )
            return .purchasedElsewhere(.desktop)
        }
    }
    
    func purchaseAvailablitiy(tier: MembershipTier, status: MembershipStatus) async -> MembershipPurchaseAvailablitiy {
        switch tier.paymentType {
        case .appStore(let info):
            return await appStoreAvailability(info: info)
        case .external(let info):
                return .external(url: info.paymentUrl)
        case nil:
            anytypeAssertionFailure(
                "No payment type for unowned tier",
                info: [
                    "Tier": String(reflecting: tier),
                    "Status": String(reflecting: status)
                ]
            )
            return .external(url: URL(string: AboutApp.pricingLink)!)
        }
    }
    
    private func appStoreAvailability(info: AppStorePaymentInfo) async -> MembershipPurchaseAvailablitiy {
        guard AppStore.canMakePayments else {
            return .external(url: info.fallbackPaymentUrl)
        }
        
        guard let isAlreadyPurchased = try? await storeKitService.isPurchased(product: info.product) else {
            return .external(url: info.fallbackPaymentUrl)
        }
        
        
        if isAlreadyPurchased {
            // In case you have already purchased subscription for other Anytype account
            return .external(url: info.fallbackPaymentUrl)
        } else {
            return .appStore(product: info.product)
        }
    }
}
