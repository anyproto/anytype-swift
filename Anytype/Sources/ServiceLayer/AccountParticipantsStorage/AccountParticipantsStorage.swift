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
    func participantPublisher(spaceId: String) -> some Publisher<Participant, Never> {
        participantsPublisher.compactMap { $0.first { $0.spaceId == spaceId } }
    }
    
    func permissionPublisher(spaceId: String) -> some Publisher<ParticipantPermissions, Never> {
        participantPublisher(spaceId: spaceId).map(\.permission).removeDuplicates()
    }
}

@MainActor
final class AccountParticipantsStorage: AccountParticipantsStorageProtocol {
    
    // MARK: - DI
    
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    private let subscriptionId = "ActiveParticipant-\(UUID())"
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - State
    
    @Published private(set) var participants: [Participant] = []
    var participantsPublisher: AnyPublisher<[Participant], Never> { $participants.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        accountManager.accountPublisher.sink { [weak self] data in
            Task {
                try await self?.startOrUpdateSubscription(info: data.info)
            }
        }.store(in: &subscriptions)
    }
    
    func stopSubscription() async {
        subscriptions.removeAll()
        try? await subscriptionStorage.stopSubscription()
    }
    
    // MARK: - Private
    
    private func startOrUpdateSubscription(info: AccountInfo) async throws {
        let filters: [DataviewFilter] = .builder {
            SearchHelper.identityProfileLink(info.profileObjectID)
            SearchHelper.layoutFilter([.participant])
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                filters: filters,
                limit: 0,
                keys: Participant.subscriptionKeys.map { $0.rawValue }
            )
        )
        
        try await subscriptionStorage.startOrUpdateSubscription(data: searchData) { [weak self] data in
            self?.participants = data.items.compactMap { try? Participant(details: $0) }
        }
    }
}
