import Services
import SwiftUI
import AnytypeCore
import StoreKit


enum MembershipNameSheetViewState: Equatable {
    case `default`
    case validating
    case error(text: String)
    case validated
    
    var isValidated: Bool {
        if case .validated = self {
            return true
        } else {
            return false
        }
    }
}

enum MembershipAnyNameAvailability {
    case notAvailable
    case availableForPruchase
    case alreadyBought
}


@MainActor
final class MembershipNameSheetViewModel: ObservableObject {
    @Published var state = MembershipNameSheetViewState.default
    let tier: MembershipTier
    let anyName: AnyName
    
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
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
            state.isValidated
        }
    }
    
    var minimumNumberOfCharacters: UInt32 {
        switch tier.anyName {
        case .none:
            anytypeAssertionFailure("Unsupported tier for name selection \(tier)")
            return .max
        case .some(let minLenght):
            return minLenght
        }
    }
    
    @Injected(\.membershipService)
    private var memberhsipService: MembershipServiceProtocol
    @Injected(\.nameService)
    private var nameService: NameServiceProtocol
    
    private var validationTask: Task<(), any Error>?
    private let product: Product
    private let onSuccessfulPurchase: (MembershipTier) -> ()
    
    init(tier: MembershipTier, anyName: AnyName, product: Product, onSuccessfulPurchase: @escaping (MembershipTier) -> ()) {
        self.tier = tier
        self.anyName = anyName
        self.product = product
        self.onSuccessfulPurchase = onSuccessfulPurchase
    }
    
    func validateName(name: String) {
        state = .default
        
        if name.count >= minimumNumberOfCharacters {
            resolveName(name: name)
        }
    }
    
    private func resolveName(name: String) {
        validationTask?.cancel()
        state = .validating
        
        validationTask = Task {
            try await Task.sleep(seconds: 0.3)
            try Task.checkCancellation()
            
            do {
                try await memberhsipService.validateName(name: name, tierType: tier.type)
                if try await nameService.isNameAvailable(name: name) {
                    state = .validated
                } else {
                    state = .error(text: Loc.thisNameIsNotAvailabe)
                }
            } catch let error {
                state = .error(text: error.localizedDescription)
            }
        }
    }
        
    func purchase(name: String) async throws {
        guard state == .validated else { return }
        
        let billingId = try await membershipService.getBillingId(name: name, tier: tier)
        try await storeKitService.purchase(product: product, billingId: billingId)
        
        onSuccessfulPurchase(tier)
    }
}
