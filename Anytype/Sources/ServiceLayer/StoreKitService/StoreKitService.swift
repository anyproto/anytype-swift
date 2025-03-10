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

public struct StoreKitPurchaseSuccess: Sendable {
    let middlewareValidationError: (any Error)?
    
    static let noError = StoreKitPurchaseSuccess(middlewareValidationError: nil)
    static func withError(_ error: some Error) -> StoreKitPurchaseSuccess {
        StoreKitPurchaseSuccess(middlewareValidationError: error)
    }
    
    func throwErrorIfNeeded() throws {
        try middlewareValidationError.flatMap { throw $0 }
    }
}

public protocol StoreKitServiceProtocol: Sendable {
    func purchase(product: Product, billingId: UUID) async throws -> StoreKitPurchaseSuccess
    func isPurchased(product: Product) async throws -> Bool
    
    func startListenForTransactions() async
    func stopListenForTransactions() async
}

actor StoreKitService: StoreKitServiceProtocol {
    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private var task: Task<(), Never>?
    
    func startListenForTransactions() {
        task = Task.detached {
            ///Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await verificationResult in Transaction.updates {
                let transaction:  Transaction
                
                do {
                    transaction = try await self.checkVerified(verificationResult)
                } catch {
                    anytypeAssertionFailure(
                        "Error in Receipt verification",
                        tags: [SentryTagKey.appArea.rawValue : SentryAppArea.payments.rawValue]
                    )
                    return
                }
                
                do {
                    ///Deliver products to the user.
                    try await self.membershipService.verifyReceipt(receipt: verificationResult.jwsRepresentation)
                    ///Always finish a transaction if delivery successful.
                    await transaction.finish()
                } catch {
                    anytypeAssertionFailure(
                        "Error in Receipt verification",
                        info: [
                            "Error": error.localizedDescription,
                            "TransactionId": String(describing: transaction.appAccountToken)
                        ],
                        tags: [SentryTagKey.appArea.rawValue : SentryAppArea.payments.rawValue]
                    )
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
    
    func purchase(product: Product, billingId: UUID) async throws -> StoreKitPurchaseSuccess {
        let result = try await product.purchase(options: [
            .appAccountToken(billingId),
            .custom(key: "BillingId", value: billingId.uuidString), // Is not working in current API
            .custom(key: "AnytypeId", value: accountManager.account.id), // Is not working in current API
        ])
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)

            do {
                try await membershipService.verifyReceipt(receipt: verificationResult.jwsRepresentation)
            } catch let error {
                // purchase successfull and verified, but still need validation from middleware
                // it will happen in startListenForTransactions asynchronously
                anytypeAssertionFailure(
                    "Error in receipt validation",
                    info: [
                        "Error": error.localizedDescription,
                        "TransactionId": String(describing: transaction.appAccountToken)
                    ],
                    tags: [SentryTagKey.appArea.rawValue : SentryAppArea.payments.rawValue]
                )
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
