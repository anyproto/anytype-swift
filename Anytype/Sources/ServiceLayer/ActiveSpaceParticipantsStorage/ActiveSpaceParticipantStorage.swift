import Foundation
import Services
import Combine

@MainActor
protocol ActiveSpaceParticipantStorageProtocol: AnyObject {
    var participants: [Participant] { get }
    var participantsPublisher: AnyPublisher<[Participant], Never> { get }
    func startSubscription() async
    func stopSubscription() async
}

extension ActiveSpaceParticipantStorageProtocol {
    var activeParticipantsPublisher: AnyPublisher<[Participant], Never> {
        participantsPublisher.map { $0.filter { $0.status == .active } }.eraseToAnyPublisher()
    }
}

@MainActor
final class ActiveSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol {
    
    // MARK: - DI
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    private let subscriptionId = "ActiveSpaceParticipant-\(UUID())"
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - State
    
    @Published private(set) var participants: [Participant] = []
    var participantsPublisher: AnyPublisher<[Participant], Never> { $participants.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        activeWorkspaceStorage.workspaceInfoPublisher.sink { [weak self] accountInfo in
            Task {
                try await self?.startOrUpdateSubscription(info: accountInfo)
            }
        }
        .store(in: &subscriptions)
    }
    
    func stopSubscription() async {
        subscriptions.removeAll()
        try? await subscriptionStorage.stopSubscription()
    }
    
    // MARK: - Private
    
    private func startOrUpdateSubscription(info: AccountInfo) async throws {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilter()
            SearchHelper.isArchivedFilter(isArchived: false)
            SearchHelper.isDeletedFilter(isDeleted: false)
            SearchHelper.spaceId(info.accountSpaceId)
            SearchHelper.layoutFilter([.participant])
            SearchHelper.participantStatusFilter(.active, .joining, .removing)

        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: Participant.subscriptionKeys.map { $0.rawValue }
            )
        )
        
        try await subscriptionStorage.startOrUpdateSubscription(data: searchData) { [weak self] data in
            self?.participants = data.items.compactMap { try? Participant(details: $0) }
        }
    }
}
