import Foundation

public typealias SafeNSItemProvider = SafeSendable<NSItemProvider>

public extension NSItemProvider {
    func sendable() -> SafeNSItemProvider {
        SafeSendable(value: self)
    }
}
