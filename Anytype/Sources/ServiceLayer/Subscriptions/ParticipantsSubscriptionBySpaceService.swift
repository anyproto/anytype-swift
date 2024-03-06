import Foundation
import Services

enum ParticipantsSubscriptionBySpaceServiceMode {
    case owner
    case member
}

@MainActor
protocol ParticipantsSubscriptionBySpaceServiceProtocol: AnyObject {
    func startSubscription(mode: ParticipantsSubscriptionBySpaceServiceMode, update: @escaping ([Participant]) -> Void) async
    func stopSubscription() async
}

@MainActor
final class ParticipantsSubscriptionBySpaceService: ParticipantsSubscriptionBySpaceServiceProtocol {
    
    @Injected(\.activeWorkpaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "SpaceParticipant-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(mode: ParticipantsSubscriptionBySpaceServiceMode, update: @escaping ([Participant]) -> Void) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilter()
            SearchHelper.isArchivedFilter(isArchived: false)
            SearchHelper.isDeletedFilter(isDeleted: false)
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId)
            SearchHelper.layoutFilter([.participant])
            switch mode {
            case .member:
                SearchHelper.participantStatusFilter(.active)
            case .owner:
                SearchHelper.participantStatusFilter(.active, .joining, .removing)
            }
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
