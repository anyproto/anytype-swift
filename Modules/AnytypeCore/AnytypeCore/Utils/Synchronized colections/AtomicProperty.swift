import Foundation

public final class AtomicProperty<T> {
    private var _value: T
    private let lock = NSLock()
    
    public init(_ value: T) {
        _value = value
    }
    
    public var value: T {
        get {
            lock.lock()
            let value = _value
            lock.unlock()
            return value
        }
        set {
            lock.lock()
            _value = newValue
            lock.unlock()
        }
    }
}
