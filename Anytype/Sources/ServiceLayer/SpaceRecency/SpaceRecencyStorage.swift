import Foundation
import AnytypeCore

protocol SpaceRecencyStorageProtocol: AnyObject, Sendable {
    func markInteraction(spaceId: String)
    func lastInteractionDates() -> [String: Date]
}

// Device-local signal for "space the user interacted with last".
// Middleware has no lastOpenedDate on space views, so quick capture records its own.
final class SpaceRecencyStorage: SpaceRecencyStorageProtocol, Sendable {

    // [SpaceId: last interaction date on this device]
    private let storage = UserDefaultStorage<[String: Date]>(key: "UserData.SpaceRecency", defaultValue: [:])

    func markInteraction(spaceId: String) {
        guard spaceId.isNotEmpty else { return }
        var dates = storage.value
        dates[spaceId] = Date.now
        storage.value = dates
    }

    func lastInteractionDates() -> [String: Date] {
        storage.value
    }
}
