import StoreKit
import AnytypeCore
import Services

enum StoreKitServiceError: String, LocalizedError {
    case userCancelled
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            Loc.purchaseCancelled
        }
    }
}

public protocol StoreKitServiceProtocol {
    func purchase(product: Product, billingId: String) async throws
    func isPurchased(product: Product) async throws -> Bool
    
    func startListenForTransactions()
    func stopListenForTransactions()
}

final class StoreKitService: StoreKitServiceProtocol {
    @Injected(\.membershipService) 
    private var membershipService: MembershipServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    private var task: Task<(), Never>?
    
    func startListenForTransactions() {
        task = Task.detached {
            ///Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await verificationResult in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(verificationResult)
                    
                    ///Deliver products to the user.
                    try await self.membershipService.verifyReceipt(billingId: "", receipt: verificationResult.jwsRepresentation)
                    
                    ///Always finish a transaction.
                    await transaction.finish()
                } catch {
                    ///StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    anytypeAssertionFailure("Error in StoreKit transaction updates", info: ["Error": error.localizedDescription])
                }
            }
        }
    }
    
    func stopListenForTransactions() {
        task?.cancel()
    }
    
    func isPurchased(product: Product) async throws -> Bool {
        guard let result = await Transaction.latest(for: product.id) else { return false }
        let transaction = try checkVerified(result)
        
        return transaction.revocationDate.isNil  
    }
    
    func purchase(product: Product, billingId: String) async throws {
        let result = try await product.purchase(options: [
            .custom(key: "AnytypeId", value: accountManager.account.id),
            .custom(key: "BillingId", value: billingId)
        ])
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)

            try await membershipService.verifyReceipt(billingId: billingId, receipt: verificationResult.jwsRepresentation)
            
            await transaction.finish()
        case .userCancelled:
            throw StoreKitServiceError.userCancelled
        case .pending:
            break // TODO support pending state
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
