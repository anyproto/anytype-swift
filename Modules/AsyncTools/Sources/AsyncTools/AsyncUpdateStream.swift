import Foundation
import os

/// A multi-subscriber stream of update sets that never loses updates.
///
/// Unlike an `AsyncStream` with `bufferingNewest(1)`, values sent while a subscriber
/// is busy are not dropped — they are merged (set union) into the subscriber's pending
/// set and delivered on its next iteration. This makes it safe to send *deltas*
/// ("messages changed", "state changed"): a slow consumer receives the union of
/// everything it missed instead of only the newest value.
///
/// Every new subscriber starts with `seed` as its pending set, so a late subscriber
/// always performs a full refresh instead of waiting for the next send.
///
/// Empty sends are no-ops. Each iterator is single-consumer.
public final class AsyncUpdateStream<T: Hashable & Sendable>: AsyncSequence, @unchecked Sendable {

    public typealias Element = Set<T>

    private struct Subscriber {
        var pending: Set<T>
        var continuation: CheckedContinuation<Set<T>?, Never>?
    }

    private let lock = OSAllocatedUnfairLock()
    private var subscribers: [UUID: Subscriber] = [:]
    private let seed: Set<T>

    public init(seed: Set<T> = []) {
        self.seed = seed
    }

    public func send(_ updates: Set<T>) {
        guard !updates.isEmpty else { return }

        lock.lock()
        var resumes = [(CheckedContinuation<Set<T>?, Never>, Set<T>)]()
        for id in subscribers.keys {
            subscribers[id]?.pending.formUnion(updates)
            if let continuation = subscribers[id]?.continuation, let pending = subscribers[id]?.pending {
                subscribers[id]?.pending = []
                subscribers[id]?.continuation = nil
                resumes.append((continuation, pending))
            }
        }
        lock.unlock()

        for (continuation, pending) in resumes {
            continuation.resume(returning: pending)
        }
    }

    public func makeAsyncIterator() -> Iterator {
        let id = UUID()
        lock.lock()
        subscribers[id] = Subscriber(pending: seed, continuation: nil)
        lock.unlock()
        return Iterator(stream: self, id: id)
    }

    public final class Iterator: AsyncIteratorProtocol {

        private let stream: AsyncUpdateStream<T>
        private let id: UUID

        fileprivate init(stream: AsyncUpdateStream<T>, id: UUID) {
            self.stream = stream
            self.id = id
        }

        deinit {
            stream.remove(id: id)
        }

        public func next() async -> Set<T>? {
            let stream = stream
            let id = id
            return await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    stream.suspend(id: id, continuation: continuation)
                }
            } onCancel: {
                stream.remove(id: id)
            }
        }
    }

    // MARK: - Private

    private func suspend(id: UUID, continuation: CheckedContinuation<Set<T>?, Never>) {
        lock.lock()

        guard var subscriber = subscribers[id] else {
            lock.unlock()
            continuation.resume(returning: nil)
            return
        }

        if !subscriber.pending.isEmpty {
            let pending = subscriber.pending
            subscriber.pending = []
            subscribers[id] = subscriber
            lock.unlock()
            continuation.resume(returning: pending)
        } else if subscriber.continuation != nil {
            // Concurrent next() calls on one iterator are not supported
            lock.unlock()
            continuation.resume(returning: nil)
        } else {
            subscriber.continuation = continuation
            subscribers[id] = subscriber
            lock.unlock()
        }
    }

    private func remove(id: UUID) {
        lock.lock()
        let continuation = subscribers[id]?.continuation
        subscribers.removeValue(forKey: id)
        lock.unlock()
        continuation?.resume(returning: nil)
    }
}
