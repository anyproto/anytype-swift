import Foundation
import Services

@MainActor
protocol SetSubscriptionDataBuilderProtocol: AnyObject {
    
    var subscriptionId: String { get }
    
    func set(_ data: SetSubscriptionData) -> SubscriptionData
}

@MainActor
final class SetSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol {
    
    let subscriptionId = "Set-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    // MARK: - SetSubscriptionDataBuilderProtocol
    
    func set(_ data: SetSubscriptionData) -> SubscriptionData {
        let numberOfRowsPerPageInSubscriptions = data.numberOfRowsPerPage

        let keys = buildKeys(with: data)
        
        let offset = (data.currentPage - 1) * numberOfRowsPerPageInSubscriptions
        
        return .search(
            SubscriptionData.Search(
                identifier: data.identifier,
                spaceId: data.spaceId,
                sorts: data.sorts,
                filters: data.filters,
                limit: numberOfRowsPerPageInSubscriptions,
                offset: offset,
                keys: keys,
                source: data.source,
                collectionId: data.collectionId
            )
        )
    }
    
    
    func buildKeys(with data: SetSubscriptionData) -> [String] {
        
        var keys: [String] = Array<BundledRelationKey>.builder {
            BundledRelationKey.id
            BundledRelationKey.name
            BundledRelationKey.snippet
            BundledRelationKey.description
            BundledRelationKey.type
            BundledRelationKey.resolvedLayout
            BundledRelationKey.isDeleted
            BundledRelationKey.done
            BundledRelationKey.coverId
            BundledRelationKey.coverScale
            BundledRelationKey.coverType
            BundledRelationKey.coverX
            BundledRelationKey.coverY
            BundledRelationKey.relationOptionColor
            BundledRelationKey.objectIconImageKeys
            BundledRelationKey.spaceId
            BundledRelationKey.source
            BundledRelationKey.chatId
        }.uniqued().map(\.rawValue)
        
        keys.append(contentsOf: data.options.map { $0.key })
        keys.append(data.coverRelationKey)
        
        return keys
    }
}
