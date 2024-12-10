import Foundation
import Combine

public final class AtomicPublishedStorage<T: Sendable>: @unchecked Sendable {
    
    private let lock = NSLock()
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
    
    public var publisher: AnyPublisher<T, Never> {
        lock.lock()
        defer { lock.unlock() }
        return subject.eraseToAnyPublisher()
    }
}
