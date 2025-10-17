import Foundation
import Services
import Combine
import AnytypeCore

protocol ParticipantsStorageProtocol: AnyObject, Sendable {
    var participants: [Participant] { get }
    var participantsPublisher: AnyPublisher<[Participant], Never> { get }
    func startSubscription() async
    func stopSubscription() async
}

extension ParticipantsStorageProtocol {
    func participantPublisher(spaceId: String) -> AnyPublisher<Participant, Never> {
        participantsPublisher.compactMap { $0.first { $0.spaceId == spaceId } }.eraseToAnyPublisher()
    }

    func permissionPublisher(spaceId: String) -> AnyPublisher<ParticipantPermissions, Never> {
        participantPublisher(spaceId: spaceId).map(\.permission).removeDuplicates().eraseToAnyPublisher()
    }

    func canEditPublisher(spaceId: String) -> AnyPublisher<Bool, Never> {
        participantPublisher(spaceId: spaceId).map(\.permission.canEdit).removeDuplicates().eraseToAnyPublisher()
    }
}

final class ParticipantsStorage: ParticipantsStorageProtocol, Sendable {

    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.Participant-"
    }

    // MARK: - DI

    private let multispaceSubscriptionHelper = MultispaceSubscriptionHelper<Participant>(
        subIdPrefix: Constants.subscriptionIdPrefix,
        subscriptionBuilder: AcountParticipantSubscriptionBuilder()
    )
    private let storage = AtomicPublishedStorage<[Participant]>([])

    // MARK: - State

    var participants: [Participant] { storage.value }
    var participantsPublisher: AnyPublisher<[Participant], Never> { storage.publisher.removeDuplicates().eraseToAnyPublisher() }

    func startSubscription() async {
        await multispaceSubscriptionHelper.startSubscription { [weak self] in
            self?.updatePartiipants()
        }
    }

    func stopSubscription() async {
        await multispaceSubscriptionHelper.stopSubscription()
        storage.value.removeAll()
    }

    // MARK: - Private

    private func updatePartiipants() {
        storage.value = multispaceSubscriptionHelper.data.values.flatMap { $0 }
    }
}
