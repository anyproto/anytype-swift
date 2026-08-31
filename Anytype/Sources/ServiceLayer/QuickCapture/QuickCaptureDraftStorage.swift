import Foundation
import AnytypeCore

protocol QuickCaptureDraftStorageProtocol: AnyObject, Sendable {
    func draftObjectId(spaceId: String) -> String?
    func setDraftObjectId(_ objectId: String?, spaceId: String)
    func lastCaptureSpaceId() -> String?
    func setLastCaptureSpaceId(_ spaceId: String)
}

// Pointers to per-space quick capture draft objects on this device.
// The draft content lives in the object itself; only the "which object is the draft" fact is local.
final class QuickCaptureDraftStorage: QuickCaptureDraftStorageProtocol, Sendable {

    // [SpaceId: draft ObjectId]
    private let storage = UserDefaultStorage<[String: String]>(key: "UserData.QuickCaptureDrafts", defaultValue: [:])
    private let lastSpaceStorage = UserDefaultStorage<String>(key: "UserData.QuickCaptureLastSpace", defaultValue: "")

    func draftObjectId(spaceId: String) -> String? {
        storage.value[spaceId]
    }

    func setDraftObjectId(_ objectId: String?, spaceId: String) {
        var drafts = storage.value
        drafts[spaceId] = objectId
        storage.value = drafts
    }

    // Where capture reopens. Separate from general space recency: opening a channel to
    // read it says nothing about where the next note belongs.
    func lastCaptureSpaceId() -> String? {
        lastSpaceStorage.value.isEmpty ? nil : lastSpaceStorage.value
    }

    func setLastCaptureSpaceId(_ spaceId: String) {
        lastSpaceStorage.value = spaceId
    }
}
