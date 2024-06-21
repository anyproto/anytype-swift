import Foundation

public enum FileSyncStatus: Int, Sendable {
    case unknown = 0
    case synced = 1
    case notSynced = 2
}
