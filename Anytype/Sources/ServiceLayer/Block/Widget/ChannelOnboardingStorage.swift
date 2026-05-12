import Foundation
import AnytypeCore
import Combine

protocol ChannelOnboardingStorageProtocol: Sendable {
    func isInviteMembersDismissed(spaceId: String) -> Bool
    func setInviteMembersDismissed(spaceId: String)

    var didChangePublisher: AnyPublisher<Void, Never> { get }
}

final class ChannelOnboardingStorage: ChannelOnboardingStorageProtocol, Sendable {

    // Historical UserDefaults key retained to preserve invite-members state for existing users.
    // Stale homepage-picker / create-home entries left in place: harmless, no migration needed.
    private let storage = UserDefaultStorage(
        key: "stubWidgetDismissals",
        defaultValue: [String: Bool]()
    )

    private let didChangeSubject = PassthroughSubject<Void, Never>()

    var didChangePublisher: AnyPublisher<Void, Never> {
        didChangeSubject.eraseToAnyPublisher()
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
        case inviteMembersDismissed
    }

    private func key(_ type: DismissalKey, spaceId: String) -> String {
        "\(spaceId)_\(type.rawValue)"
    }
}
