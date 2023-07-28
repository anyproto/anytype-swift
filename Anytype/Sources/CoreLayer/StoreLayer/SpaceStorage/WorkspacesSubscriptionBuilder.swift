import Foundation
import Services
import AnytypeCore

protocol WorkspacesSubscriptionBuilderProtocol: AnyObject {
    func build() -> SubscriptionData
}

private extension SubscriptionId {
    static var spaces = SubscriptionId(value: "SubscriptionId.Workspaces")
}

final class WorkspacesSubscriptionBuilder: WorkspacesSubscriptionBuilderProtocol {
    
    // MARK: - WorkspacesSubscriptionBuilderProtocol
    
    func build() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.id,
            type: .asc
        )
        
        let filters = [
            SearchHelper.layoutFilter([.space])
        ]
        
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.id
            BundledRelationKey.spaceId
            BundledRelationKey.titleKeys
        }.uniqued()
        
        return .search(
            SubscriptionData.Search(
                identifier: .spaces,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: keys.map(\.rawValue)
            )
        )
    }
}
