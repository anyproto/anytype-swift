import Foundation
import Services
import AnytypeCore

protocol WorkspacesSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build(techSpaceId: String) -> SubscriptionData
}

final class WorkspacesSubscriptionBuilder: WorkspacesSubscriptionBuilderProtocol {
    
    private enum Constants {
        static let spacesSubId = "SubscriptionId.Workspaces"
    }
    
    // MARK: - WorkspacesSubscriptionBuilderProtocol
    
    var subscriptionId: String {
        Constants.spacesSubId
    }
    
    func build(techSpaceId: String) -> SubscriptionData {
        let sorts: [DataviewSort] = .builder {
            SearchHelper.sort(relation: .spaceOrder, type: .asc, noCollate: true, emptyPlacement: .end)
            // TODO: lastMessageDate sort
            SearchHelper.sort(relation: .createdDate, type: .desc)
        }
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.spaceView])
            SearchHelper.spaceAccountStatusExcludeFilter(.spaceDeleted)
        }
        
        return .search(
            SubscriptionData.Search(
                identifier: Constants.spacesSubId,
                spaceId: techSpaceId,
                sorts: sorts,
                filters: filters,
                limit: 0,
                offset: 0,
                keys: SpaceView.subscriptionKeys.map(\.rawValue)
            )
        )
    }
}
