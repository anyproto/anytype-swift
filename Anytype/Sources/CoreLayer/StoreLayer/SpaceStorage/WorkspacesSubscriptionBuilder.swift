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
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.layoutFilter([.spaceView])
        ]
        
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.id
            BundledRelationKey.targetSpaceId
            BundledRelationKey.titleKeys
            BundledRelationKey.objectIconImageKeys
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
