import Foundation
import Combine

protocol ParticipantsStorageProtocol: AnyObject {
    func startSubscription() async
    func stopSubscription() async
    func participantsPublisher(spaceId: String) -> AnyPublisher<[Participant], Never>
    func accountParticipantsPublisher() -> AnyPublisher<[Participant], Never>
}

final class ParticipantsStorage: ParticipantsStorageProtocol {
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let subscriptionBuilder: ParticipantsSubscriptionBuilderProtocol
    private let accountManager: AccountManagerProtocol
    
    @Published private var participants: [Participant] = []
    
    init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        subscriptionBuilder: ParticipantsSubscriptionBuilderProtocol,
        accountManager: AccountManagerProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
        self.subscriptionBuilder = subscriptionBuilder
        self.accountManager = accountManager
    }
    
    func startSubscription() async {
        let data = subscriptionBuilder.build()
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            participants = data.items.compactMap { try? Participant(details: $0) }
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
    
    func participantsPublisher(spaceId: String) -> AnyPublisher<[Participant], Never> {
        return $participants
            .map { $0.filter { $0.spaceId == spaceId } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func accountParticipantsPublisher() -> AnyPublisher<[Participant], Never> {
        let accountId = accountManager.account.id
        return $participants
            .map { $0.filter { $0.identity == accountId } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
