import Foundation
import AnytypeCore

protocol StubWidgetDismissalStorageProtocol: Sendable {
    func isHomepagePickerDismissed(spaceId: String) -> Bool
    func setHomepagePickerDismissed(spaceId: String)

    func isCreateHomeDismissed(spaceId: String) -> Bool
    func setCreateHomeDismissed(spaceId: String)
    func resetCreateHomeDismissed(spaceId: String)

    func isInviteMembersDismissed(spaceId: String) -> Bool
    func setInviteMembersDismissed(spaceId: String)
}

final class StubWidgetDismissalStorage: StubWidgetDismissalStorageProtocol, Sendable {

    private let storage = UserDefaultStorage(
        key: "stubWidgetDismissals",
        defaultValue: [String: Bool]()
    )

    // MARK: - Homepage Picker

    func isHomepagePickerDismissed(spaceId: String) -> Bool {
        storage.value[key(.homepagePickerDismissed, spaceId: spaceId)] ?? false
    }

    func setHomepagePickerDismissed(spaceId: String) {
        storage.value[key(.homepagePickerDismissed, spaceId: spaceId)] = true
    }

    // MARK: - Create Home Widget

    func isCreateHomeDismissed(spaceId: String) -> Bool {
        storage.value[key(.createHomeDismissed, spaceId: spaceId)] ?? false
    }

    func setCreateHomeDismissed(spaceId: String) {
        storage.value[key(.createHomeDismissed, spaceId: spaceId)] = true
    }

    /// Reset dismissal when homepage becomes non-empty.
    /// This ensures the widget can reappear if homepage is later reset to empty
    /// (e.g. the homepage object was deleted and middleware cleared the value).
    func resetCreateHomeDismissed(spaceId: String) {
        storage.value[key(.createHomeDismissed, spaceId: spaceId)] = nil
    }

    // MARK: - Invite Members Widget

    func isInviteMembersDismissed(spaceId: String) -> Bool {
        storage.value[key(.inviteMembersDismissed, spaceId: spaceId)] ?? false
    }

    func setInviteMembersDismissed(spaceId: String) {
        storage.value[key(.inviteMembersDismissed, spaceId: spaceId)] = true
    }

    // MARK: - Private

    private enum DismissalKey: String {
        case homepagePickerDismissed
        case createHomeDismissed
        case inviteMembersDismissed
    }

    private func key(_ type: DismissalKey, spaceId: String) -> String {
        "\(spaceId)_\(type.rawValue)"
    }
}
