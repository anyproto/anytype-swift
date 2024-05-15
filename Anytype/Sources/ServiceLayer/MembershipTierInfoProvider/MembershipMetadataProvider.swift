import Services
import AnytypeCore
import StoreKit


protocol MembershipMetadataProviderProtocol {
    func owningState(tier: MembershipTier) async -> MembershipTierOwningState
    
    func purchaseType(status: MembershipStatus) async -> MembershipPurchaseType
    func purchaseAvailablitiy(tier: MembershipTier) async -> MembershipPurchaseAvailablitiy
}

final class MembershipMetadataProvider: MembershipMetadataProviderProtocol {
    @Injected(\.membershipStatusStorage)
    private var storage: MembershipStatusStorageProtocol
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    
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
        
        let purchaseAvailablitiy = await purchaseAvailablitiy(tier: tier)
        return .unowned(purchaseAvailablitiy)
    }
    
                
    func purchaseType(status: MembershipStatus) async -> MembershipPurchaseType {
        guard status.paymentMethod == .methodInappApple else {
            return .purchasedElsewhere
        }
        
        switch status.tier?.paymentType {
        case .appStore(let info):
            guard let isPurchased = try? await storeKitService.isPurchased(product: info.product) else {
                return .purchasedElsewhere
            }
            
            return isPurchased ? .purchasedInAppStoreWithCurrentAccount : .purchasedInAppStoreWithOtherAccount
        case .external, nil:
            return .purchasedElsewhere
        }
    }
    
    func purchaseAvailablitiy(tier: MembershipTier) async -> MembershipPurchaseAvailablitiy {
        switch tier.paymentType {
        case .appStore(let info):
            return await appStoreAvailability(info: info)
        case .external(let info):
                return .external(url: info.paymentUrl)
        case nil:
            anytypeAssertionFailure(
                "No payment type for unowned tier",
                info: ["Tier": String(reflecting: tier)]
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
