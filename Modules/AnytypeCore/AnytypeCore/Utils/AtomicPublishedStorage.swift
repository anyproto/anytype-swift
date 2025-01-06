import Foundation
import Combine
import os

public final class AtomicPublishedStorage<T: Sendable>: @unchecked Sendable {
    
    private let lock = OSAllocatedUnfairLock()
    private let subject: CurrentValueSubject<T, Never>
    
    public init(_ value: T) {
        subject = CurrentValueSubject(value)
    }
    
    public var value: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return subject.value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            subject.send(newValue)
        }
    }
    
    public var publisher: some Publisher<T, Never> {
        lock.lock()
        defer { lock.unlock() }
        return subject.eraseToAnyPublisher()
    }
}
