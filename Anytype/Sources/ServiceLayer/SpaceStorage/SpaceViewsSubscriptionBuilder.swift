import Foundation
import Services
import AnytypeCore

protocol SpaceViewsSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build(techSpaceId: String) -> SubscriptionData
}

final class SpaceViewsSubscriptionBuilder: SpaceViewsSubscriptionBuilderProtocol {

    private enum Constants {
        static let spacesSubId = "SubscriptionId.SpaceViews"
    }

    // MARK: - SpaceViewsSubscriptionBuilderProtocol

    var subscriptionId: String {
        Constants.spacesSubId
    }

    func build(techSpaceId: String) -> SubscriptionData {
        let sorts: [DataviewSort] = .builder {
            SearchHelper.sort(relation: .spaceOrder, type: .asc, noCollate: true, emptyPlacement: .end)
            SearchHelper.sort(relation: .spaceJoinDate, type: .desc)
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
