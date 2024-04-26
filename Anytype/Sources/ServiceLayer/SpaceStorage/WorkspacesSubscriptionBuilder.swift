import Foundation
import Services
import AnytypeCore

protocol WorkspacesSubscriptionBuilderProtocol: AnyObject {
    var subscriptionId: String { get }
    func build() -> SubscriptionData
}

final class WorkspacesSubscriptionBuilder: WorkspacesSubscriptionBuilderProtocol {
    
    private enum Constants {
        static let spacesSubId = "SubscriptionId.Workspaces"
    }
    
    // MARK: - WorkspacesSubscriptionBuilderProtocol
    
    var subscriptionId: String {
        Constants.spacesSubId
    }
    
    func build() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.spaceView])
            SearchHelper.spaceAccountStatusExcludeFilter(.spaceDeleted)
        }
        
        return .search(
            SubscriptionData.Search(
                identifier: Constants.spacesSubId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: SpaceView.subscriptionKeys.map(\.rawValue)
            )
        )
    }
}
