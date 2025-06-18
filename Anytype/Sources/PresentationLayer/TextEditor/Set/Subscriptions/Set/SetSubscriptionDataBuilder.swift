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
        
        return keys
    }
}
