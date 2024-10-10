import Foundation
import Services
import Combine

@MainActor
protocol AccountParticipantsStorageProtocol: AnyObject {
    var participants: [Participant] { get }
    var participantsPublisher: AnyPublisher<[Participant], Never> { get }
    func startSubscription() async
    func stopSubscription() async
}

extension AccountParticipantsStorageProtocol {
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

@MainActor
final class AccountParticipantsStorage: AccountParticipantsStorageProtocol {
    
    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.AccountParticipant-"
    }
    
    // MARK: - DI
    
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
    private lazy var multispaceSubscriptionHelper = MultispaceSubscriptionHelper<Participant>(
        subIdPrefix: Constants.subscriptionIdPrefix,
        subscriptionBuilder: AcountParticipantSubscriptionBuilder(profileObjectId: accountManager.account.info.profileObjectID)
    )
    
    // MARK: - State
    
    @Published private(set) var participants: [Participant] = []
    var participantsPublisher: AnyPublisher<[Participant], Never> { $participants.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        await multispaceSubscriptionHelper.startSubscription { [weak self] in
            self?.updatePartiipants()
        }
    }
    
    func stopSubscription() async {
        await multispaceSubscriptionHelper.stopSubscription()
        participants.removeAll()
    }
    
    // MARK: - Private
    
    private func updatePartiipants() {
        participants = multispaceSubscriptionHelper.data.values.flatMap { $0 }
    }
}
