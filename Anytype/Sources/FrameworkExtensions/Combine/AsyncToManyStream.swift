import Foundation
import os

final class AsyncToManyStream<T>: AsyncSequence, @unchecked Sendable where T: Sendable {
    
    typealias Element = T
    typealias AsyncIterator = AsyncStream<T>.AsyncIterator

    private var continuations: [UUID: AsyncStream<T>.Continuation] = [:]
    private let lock = OSAllocatedUnfairLock()
    
    func makeAsyncIterator() -> AsyncIterator {
        subscribe().makeAsyncIterator()
    }

    func subscribe() -> AsyncStream<T> {
        return AsyncStream { continuation in
            let id = UUID()
            self.continuations[id] = continuation

            continuation.onTermination = { _ in
                self.removeContinuation(id)
            }
        }
    }

    func send(_ value: T) {
        lock.lock()
        defer { lock.unlock() }
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }

    func finish() {
        lock.lock()
        defer { lock.unlock() }
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }

    private func removeContinuation(_ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        continuations.removeValue(forKey: id)
    }
}
