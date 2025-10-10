import Foundation
import os

public func withUncancellableHandler<T: Sendable>(
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    let box = ResumeBox<T>()

    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<T, Error>) in

            box.setContinuation(cont)

            let task = Task<Void, Never> {
                do {
                    let value = try await operation()
                    box.resume(returning: value)
                } catch {
                    box.resume(throwing: error)
                }
            }
            box.setTask(task)
        }
    } onCancel: {
        box.cancelAndFail()
    }
}

private final class ResumeBox<T: Sendable>: @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock()
    private var cont: CheckedContinuation<T, Error>?
    private var task: Task<Void, Never>?

    func setContinuation(_ c: CheckedContinuation<T, Error>) {
        lock.withLock { cont = c }
    }

    func setTask(_ t: Task<Void, Never>) {
        lock.withLock { task = t }
    }

    func resume(returning value: T) {
        lock.withLock {
            guard let c = cont else { return }
            cont = nil
            c.resume(returning: value)
        }
    }

    func resume(throwing error: Error) {
        lock.withLock {
            guard let c = cont else { return }
            cont = nil
            c.resume(throwing: error)
        }
    }

    func cancelAndFail() {
        lock.withLock {
            task?.cancel()
        }
        resume(throwing: CancellationError())
    }
}
