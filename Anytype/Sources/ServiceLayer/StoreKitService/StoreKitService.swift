import StoreKit
import AnytypeCore
import Services

enum StoreKitServiceError: String, LocalizedError {
    case userCancelled
    case needUserAction
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            Loc.StoreKitServiceError.userCancelled
        case .needUserAction:
            Loc.StoreKitServiceError.needUserAction
        }
    }
}

public struct StoreKitPurchaseSuccess {
    let middlewareValidationError: Error?
    
    static let noError = StoreKitPurchaseSuccess(middlewareValidationError: nil)
    static func withError(_ error: Error) -> StoreKitPurchaseSuccess {
        StoreKitPurchaseSuccess(middlewareValidationError: error)
    }
    
    func throwErrorIfNeeded() throws {
        try middlewareValidationError.flatMap { throw $0 }
    }
}

public protocol StoreKitServiceProtocol {
    func purchase(product: Product, billingId: String) async throws -> StoreKitPurchaseSuccess
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
    
    func purchase(product: Product, billingId: String) async throws -> StoreKitPurchaseSuccess {
        let result = try await product.purchase(options: [
            .custom(key: "BillingId", value: billingId), // Is not working in current API
            .custom(key: "AnytypeId", value: accountManager.account.id), // Is not working in current API
        ])
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)

            do {
                try await membershipService.verifyReceipt(billingId: billingId, receipt: verificationResult.jwsRepresentation)
            } catch let error {
                // purchase successfull and verified, but still need validation from middleware
                // it will happen in startListenForTransactions asynchronously
                return .withError(error)
            }
            
            await transaction.finish()
            return .noError
        case .userCancelled:
            throw StoreKitServiceError.userCancelled
        case .pending:
            throw StoreKitServiceError.needUserAction
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
