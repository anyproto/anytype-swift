import Services
import SwiftUI
import AnytypeCore
import StoreKit


enum MembershipAnyNameAvailability {
    case notAvailable
    case availableForPruchase
    case alreadyBought
}


@MainActor
final class MembershipNameSheetViewModel: ObservableObject {
    @Published var isNameValidated = false
    
    let tier: MembershipTier
    let anyName: AnyName
    
    var anyNameAvailability: MembershipAnyNameAvailability {
        switch tier.anyName {
        case .none:
            .notAvailable
        case .some:
            if anyName.handle.isEmpty {
                .availableForPruchase
            } else {
                .alreadyBought
            }
        }
    }
    
    var canBuyTier: Bool {
        switch anyNameAvailability {
        case .notAvailable, .alreadyBought:
            true
        case .availableForPruchase:
            isNameValidated
        }
    }
    
    private let product: Product
    private let onSuccessfulPurchase: (MembershipTier) -> ()
    
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    init(tier: MembershipTier, anyName: AnyName, product: Product, onSuccessfulPurchase: @escaping (MembershipTier) -> ()) {
        self.tier = tier
        self.anyName = anyName
        self.product = product
        self.onSuccessfulPurchase = onSuccessfulPurchase
    }
        
    func purchase(name: String) async throws {
        guard canBuyTier else { return }
        
        let billingId = try await membershipService.getBillingId(name: name, tier: tier)
        let result = try await storeKitService.purchase(product: product, billingId: billingId)
        
        onSuccessfulPurchase(tier)
        try result.throwErrorIfNeeded()
    }
}
