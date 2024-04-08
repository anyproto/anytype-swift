import StoreKit
import AnytypeCore


public protocol StoreKitServiceProtocol {
    func purchase(product: Product) async throws
    
    func startListenForTransactions()
    func stopListenForTransactions()
}

final class StoreKitService: StoreKitServiceProtocol {
    private var task: Task<(), Never>?
    
    func startListenForTransactions() {
        task = Task.detached {
            ///Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await verificationResult in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(verificationResult)
                    
                    ///Deliver products to the user.
                    try await self.notifyMiddleware()
                    
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
    
    func purchase(product: Product) async throws {
        let result = try await product.purchase(options: [
            .appAccountToken(UUID()),
            .custom(key: "TODO", value: "SEND_DATA") // TODO
        ])
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            try await notifyMiddleware()
            await transaction.finish()
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
    
    private func notifyMiddleware() async throws {
        // TODO
    }
}
