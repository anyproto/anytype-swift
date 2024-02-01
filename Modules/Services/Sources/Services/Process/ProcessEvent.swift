import Foundation

public enum ProcessEvent {
    case new(Process)
    case update(Process)
    case done(Process)
}
