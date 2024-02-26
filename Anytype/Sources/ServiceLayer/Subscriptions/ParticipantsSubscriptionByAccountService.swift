import Foundation
import Services

@MainActor
protocol ParticipantsSubscriptionByAccountServiceProtocol: AnyObject {
    func startSubscription(update: @escaping ([Participant]) -> Void) async
    func stopSubscription() async
}

@MainActor
final class ParticipantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol {
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionId = "AccountParticipant-\(UUID().uuidString)"
    
    nonisolated init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    func startSubscription(update: @escaping ([Participant]) -> Void) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.identityProfileLink(activeWorkspaceStorage.workspaceInfo.profileObjectID),
            SearchHelper.layoutFilter([.participant])
        ]
        
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
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            let items = data.items
                .compactMap { try? Participant(details: $0) }
            update(items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
