import Foundation
import Services
import AnytypeCore

protocol SetSubscriptionDataBuilderProtocol: AnyObject, Sendable {
    
    var subscriptionId: String { get }
    
    func set(_ data: SetSubscriptionData) -> SubscriptionData
}

final class SetSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol, Sendable {

    let subscriptionId = "Set-\(UUID().uuidString)"

    @Injected(\.participantsStorage)
    private var participantsStorage: any ParticipantsStorageProtocol

    init() {}

    // MARK: - SetSubscriptionDataBuilderProtocol

    func set(_ data: SetSubscriptionData) -> SubscriptionData {
        let numberOfRowsPerPageInSubscriptions = data.numberOfRowsPerPage

        let keys = buildKeys(with: data)

        let offset = max((data.currentPage - 1) * numberOfRowsPerPageInSubscriptions, 0)

        let participantId = participantsStorage.participants
            .first { $0.spaceId == data.spaceId }?.id
        let filters = data.filters
            .resolvingCurrentUserPlaceholder(participantId: participantId)

        return .search(
            SubscriptionData.Search(
                identifier: data.identifier,
                spaceId: data.spaceId,
                sorts: data.sorts,
                filters: filters,
                limit: numberOfRowsPerPageInSubscriptions,
                offset: offset,
                keys: keys,
                source: data.source,
                collectionId: data.collectionId
            )
        )
    }
    
    
    func buildKeys(with data: SetSubscriptionData) -> [String] {
        
        var keys: [String] = Array<BundledPropertyKey>.builder {
            BundledPropertyKey.id
            BundledPropertyKey.name
            BundledPropertyKey.pluralName
            BundledPropertyKey.snippet
            BundledPropertyKey.description
            BundledPropertyKey.type
            BundledPropertyKey.resolvedLayout
            BundledPropertyKey.isDeleted
            BundledPropertyKey.done
            BundledPropertyKey.coverId
            BundledPropertyKey.coverScale
            BundledPropertyKey.coverType
            BundledPropertyKey.coverX
            BundledPropertyKey.coverY
            BundledPropertyKey.relationOptionColor
            BundledPropertyKey.objectIconImageKeys
            BundledPropertyKey.spaceId
            BundledPropertyKey.source
            BundledPropertyKey.chatId
        }.uniqued().map(\.rawValue)
        
        keys.append(contentsOf: data.options.map { $0.key })
        keys.append(data.coverRelationKey)
        if let groupRelationKey = data.groupRelationKey {
            keys.append(groupRelationKey)
        }

        return keys
    }
}
