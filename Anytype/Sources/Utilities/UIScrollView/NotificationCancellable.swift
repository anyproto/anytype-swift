import Foundation

// Delete after implementation https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
final class NotificationCancellable {
    
    private let token: any NSObjectProtocol
    
    init(_ token: any NSObjectProtocol) {
        self.token = token
    }
    
    deinit {
        NotificationCenter.default.removeObserver(token)
    }
}

extension NSObjectProtocol {
    func notificationCancellable() -> NotificationCancellable {
        NotificationCancellable(self)
    }
}
