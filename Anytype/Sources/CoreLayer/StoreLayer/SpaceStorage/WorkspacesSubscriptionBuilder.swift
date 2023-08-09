import Foundation
import Services
import AnytypeCore

protocol WorkspacesSubscriptionBuilderProtocol: AnyObject {
    func build() -> SubscriptionData
}

final class WorkspacesSubscriptionBuilder: WorkspacesSubscriptionBuilderProtocol {
    
    private enum Constants {
        static let spacesSubId = "SubscriptionId.Workspaces"
    }
    
    // MARK: - WorkspacesSubscriptionBuilderProtocol
    
    func build() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.createdDate,
            type: .asc
        )
        
        let filters = [
            SearchHelper.typeFilter(typeIds: [ObjectTypeId.bundled(.space).rawValue])
        ]
        
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.id
            BundledRelationKey.spaceId
            BundledRelationKey.titleKeys
        }.uniqued()
        
        return .search(
            SubscriptionData.Search(
                identifier: Constants.spacesSubId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: keys.map(\.rawValue)
            )
        )
    }
}
