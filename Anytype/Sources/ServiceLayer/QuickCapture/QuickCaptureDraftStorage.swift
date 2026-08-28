import Foundation
import AnytypeCore

protocol QuickCaptureDraftStorageProtocol: AnyObject, Sendable {
    func draftObjectId(spaceId: String) -> String?
    func setDraftObjectId(_ objectId: String?, spaceId: String)
}

// Pointers to per-space quick capture draft objects on this device.
// The draft content lives in the object itself; only the "which object is the draft" fact is local.
final class QuickCaptureDraftStorage: QuickCaptureDraftStorageProtocol, Sendable {

    // [SpaceId: draft ObjectId]
    private let storage = UserDefaultStorage<[String: String]>(key: "UserData.QuickCaptureDrafts", defaultValue: [:])

    func draftObjectId(spaceId: String) -> String? {
        storage.value[spaceId]
    }

    func setDraftObjectId(_ objectId: String?, spaceId: String) {
        var drafts = storage.value
        drafts[spaceId] = objectId
        storage.value = drafts
    }
}
