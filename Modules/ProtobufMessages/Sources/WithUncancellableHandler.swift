import Foundation

func withUncancellableHandler<T>(operation: @escaping @Sendable () async throws -> T) async rethrows -> T {
    let cancelClosure = ClosureStorage()
    
    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try await operation()
                    if !cancelClosure.isCancelled {
                        continuation.resume(returning: result)
                    }
                } catch {
                    if !cancelClosure.isCancelled {
                        continuation.resume(throwing: error)
                    }
                }
            }
            cancelClosure.closure = {
                continuation.resume(throwing: CancellationError())
            }
        }
    } onCancel: {
        cancelClosure.isCancelled = true
        cancelClosure.closure?()
    }
}

private final class ClosureStorage: @unchecked Sendable {
    var isCancelled: Bool = false
    var closure: (() -> Void)?
}
