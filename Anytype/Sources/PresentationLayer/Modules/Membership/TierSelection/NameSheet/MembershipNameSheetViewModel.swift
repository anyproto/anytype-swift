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
@Observable
final class MembershipNameSheetViewModel {
    var isNameValidated = false

    @ObservationIgnored
    let tier: MembershipTier
    @ObservationIgnored
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

    @ObservationIgnored
    private let product: Product
    @ObservationIgnored
    private let onSuccessfulPurchase: (MembershipTier) -> ()

    @ObservationIgnored @Injected(\.storeKitService)
    private var storeKitService: any StoreKitServiceProtocol
    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    
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
