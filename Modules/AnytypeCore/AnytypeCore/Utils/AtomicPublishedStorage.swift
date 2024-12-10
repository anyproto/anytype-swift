import Foundation
import Combine

public final class AtomicPublishedStorage<T: Sendable>: @unchecked Sendable {
    
    private let queue = DispatchQueue(label: "AtomicPublishedStorageQueue", attributes: .concurrent)
    private let subject: CurrentValueSubject<T, Never>
    
    public init(_ value: T) {
        subject = CurrentValueSubject(value)
    }
    
    public var value: T {
        get {
            queue.sync {
                subject.value
            }
        }
        set {
            queue.async(flags: .barrier) {
                self.subject.send(newValue)
            }
        }
    }
    
    public var publisher: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
}
