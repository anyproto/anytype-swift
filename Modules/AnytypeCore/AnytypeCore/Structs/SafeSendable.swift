import Foundation

public struct SafeSendable<T>: @unchecked Sendable {
    private var _value: T
    private let sendableLock = DispatchQueue(label: "safeSendable.lock.queue")
    
    public var value: T {
        set {
            sendableLock.sync {
                _value = newValue
            }
        }
        
        get {
            return sendableLock.sync {
                _value
            }
        }
    }
    
    public init(value: T) {
        _value = value
    }
}
