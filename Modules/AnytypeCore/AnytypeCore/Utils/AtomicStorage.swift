import Foundation
import Combine
import os

public final class AtomicStorage<T>: @unchecked Sendable {
    
    private let lock = OSAllocatedUnfairLock()
    private var storage: T
    
    public init(_ value: T) {
        storage = value
    }
    
    public var value: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storage
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storage = newValue
        }
    }
    
    @discardableResult
    public func access<R>(_ closure: (_ value: inout T) -> R) -> R {
        lock.lock()
        defer { lock.unlock() }
        return closure(&storage)
    }
}
