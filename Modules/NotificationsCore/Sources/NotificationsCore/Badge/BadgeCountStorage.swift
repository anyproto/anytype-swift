import Foundation
import AnytypeCore
import Factory

public protocol BadgeCountStorageProtocol: AnyObject, Sendable {
    var badgeCount: Int { get set }
}

final class BadgeCountStorage: BadgeCountStorageProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private let userDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    private let key = "AppIconBadgeCount"

    var badgeCount: Int {
        get {
            lock.lock()
            defer { lock.unlock() }
            return userDefaults?.integer(forKey: key) ?? 0
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            userDefaults?.set(newValue, forKey: key)
        }
    }
}

public extension Container {

    var badgeCountStorage: Factory<any BadgeCountStorageProtocol> {
        self { BadgeCountStorage() }.singleton
    }

}
