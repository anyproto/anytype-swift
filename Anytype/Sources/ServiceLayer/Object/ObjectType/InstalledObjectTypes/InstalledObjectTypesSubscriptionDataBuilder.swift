import Foundation
import Services

protocol InstalledObjectTypesSubscriptionDataBuilderProtocol: AnyObject {
    func build() -> SubscriptionData
}

final class InstalledObjectTypesSubscriptionDataBuilder: InstalledObjectTypesSubscriptionDataBuilderProtocol {

    private let accountManager: AccountManagerProtocol

    init(accountManager: AccountManagerProtocol) {
        self.accountManager = accountManager
    }

    // MARK: - RelationSubscriptionDataBuilderProtocol
    
    func build() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )

        let filters: [DataviewFilter] = .builder {
            SearchHelper.buildFilters(
                isArchived: false,
                workspaceId: accountManager.account.info.accountSpaceId
            )
            SearchHelper.layoutFilter([DetailsLayout.objectType])
            SearchHelper.recomendedLayoutFilter(DetailsLayout.visibleLayouts)
        }

        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.iconEmoji.rawValue,
            BundledRelationKey.description.rawValue,
            BundledRelationKey.recommendedLayout.rawValue,
            BundledRelationKey.defaultTemplateId.rawValue
        ]

        return .search(
            SubscriptionData.Search(
                identifier: InstalledObjectTypesProvider.subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: keys
            )
        )
    }
}
