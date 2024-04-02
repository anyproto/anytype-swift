import Foundation
import Services
import Combine

@MainActor
protocol ActiveSpaceParticipantStorageProtocol: AnyObject {
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
    
    private var participantsSubject = CurrentValueSubject<[Participant], Never>([])
    var participantsPublisher: AnyPublisher<[Participant], Never> { participantsSubject.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        activeWorkspaceStorage.workspaceInfoPublisher
            .map(\.accountSpaceId)
            .removeDuplicates()
            .sink { [weak self] spaceId in
                Task {
                    // TODO: Make different publisher for each space. Imrove subscriptions.
                    // IOS-2518
                    // For prevent affest on screen when user switch, create a new subject
                    self?.participantsSubject = CurrentValueSubject<[Participant], Never>([])
                    try await self?.startOrUpdateSubscription(spaceId: spaceId)
                }
            }
            .store(in: &subscriptions)
    }
    
    func stopSubscription() async {
        subscriptions.removeAll()
        try? await subscriptionStorage.stopSubscription()
    }
    
    // MARK: - Private
    
    private func startOrUpdateSubscription(spaceId: String) async throws {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(allowHiddenDiscovery: false)
            SearchHelper.spaceId(spaceId)
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
            let participants = data.items.compactMap { try? Participant(details: $0) }
            self?.participantsSubject.send(participants)
        }
    }
}
