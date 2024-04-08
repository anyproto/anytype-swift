import Services
import SwiftUI
import AnytypeCore
import StoreKit


enum MembershipNameSheetViewState {
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
    let anyName: String
    
    var anyNameAvailability: MembershipAnyNameAvailability {
        switch tier.anyName {
        case .none:
            .notAvailable
        case .some:
            if anyName.isEmpty {
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
    
    private var validationTask: Task<(), any Error>?
    private let product: Product
    private let onSuccessfulPurchase: (MembershipTier) -> ()
    
    init(tier: MembershipTier, anyName: String, product: Product, onSuccessfulPurchase: @escaping (MembershipTier) -> ()) {
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
            try await Task.sleep(seconds: 0.5)
            try Task.checkCancellation()
            
            do {
                try await memberhsipService.validateName(name: "\(name).any", tierType: tier.type)
                state = .validated
            } catch let error as MembershipServiceProtocol.ValidateNameError {
                state = .error(text: error.validateNameSheetError)
            } catch let error {
                state = .error(text: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Purchase
    
    func purchase() async throws {
        let result = try await product.purchase(options: [
            .appAccountToken(UUID()),
            .custom(key: "TODO", value: "SEND_DATA")
        ])
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            // TODO: Update middleware
            await transaction.finish()
            onSuccessfulPurchase(tier)
        case .userCancelled:
            break // TODO
        case .pending:
            break // TODO
        @unknown default:
            anytypeAssertionFailure("Unsupported purchase result \(result)")
            fatalError()
        }
    }
    
    private func checkVerified<T>(_ verificationResult: VerificationResult<T>) throws -> T {
        switch verificationResult {
        case .unverified(_, let verificationError):
            throw verificationError
        case .verified(let signedType):
            return signedType
        }
    }
}
