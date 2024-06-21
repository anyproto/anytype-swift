import Foundation

public enum ProcessEvent: Sendable {
    case new(Process)
    case update(Process)
    case done(Process)
}
