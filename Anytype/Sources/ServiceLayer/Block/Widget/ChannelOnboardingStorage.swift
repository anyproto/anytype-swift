import Foundation
import AnytypeCore
import Combine

protocol ChannelOnboardingStorageProtocol: Sendable {
    func isHomepagePickerDismissed(spaceId: String) -> Bool
    func setHomepagePickerDismissed(spaceId: String)

    func isCreateHomeDismissed(spaceId: String) -> Bool
    func setCreateHomeDismissed(spaceId: String)
    func resetCreateHomeDismissed(spaceId: String)

    func isInviteMembersDismissed(spaceId: String) -> Bool
    func setInviteMembersDismissed(spaceId: String)

    var didChangePublisher: AnyPublisher<Void, Never> { get }
}

final class ChannelOnboardingStorage: ChannelOnboardingStorageProtocol, Sendable {

    private let storage = UserDefaultStorage(
        key: "stubWidgetDismissals",
        defaultValue: [String: Bool]()
    )

    private let didChangeSubject = PassthroughSubject<Void, Never>()

    var didChangePublisher: AnyPublisher<Void, Never> {
        didChangeSubject.eraseToAnyPublisher()
    }

    // MARK: - Homepage Picker

    func isHomepagePickerDismissed(spaceId: String) -> Bool {
        storage.value[key(.homepagePickerDismissed, spaceId: spaceId)] ?? false
    }

    func setHomepagePickerDismissed(spaceId: String) {
        storage.value[key(.homepagePickerDismissed, spaceId: spaceId)] = true
        didChangeSubject.send()
    }

    // MARK: - Create Home Widget

    func isCreateHomeDismissed(spaceId: String) -> Bool {
        storage.value[key(.createHomeDismissed, spaceId: spaceId)] ?? false
    }

    func setCreateHomeDismissed(spaceId: String) {
        storage.value[key(.createHomeDismissed, spaceId: spaceId)] = true
        didChangeSubject.send()
    }

    /// Reset dismissal when homepage becomes non-empty.
    /// This ensures the widget can reappear if homepage is later reset to empty
    /// (e.g. the homepage object was deleted and middleware cleared the value).
    func resetCreateHomeDismissed(spaceId: String) {
        storage.value[key(.createHomeDismissed, spaceId: spaceId)] = nil
        didChangeSubject.send()
    }

    // MARK: - Invite Members Widget

    func isInviteMembersDismissed(spaceId: String) -> Bool {
        storage.value[key(.inviteMembersDismissed, spaceId: spaceId)] ?? false
    }

    func setInviteMembersDismissed(spaceId: String) {
        storage.value[key(.inviteMembersDismissed, spaceId: spaceId)] = true
        didChangeSubject.send()
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
