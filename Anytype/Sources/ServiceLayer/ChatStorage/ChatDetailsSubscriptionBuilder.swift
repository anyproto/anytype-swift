import Foundation
import Services
import AnytypeCore

protocol ChatDetailsSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build() -> SubscriptionData
}

final class ChatDetailsSubscriptionBuilder: ChatDetailsSubscriptionBuilderProtocol {

    private enum Constants {
        static let chatsSubId = "SubscriptionId.ChatViews"
    }

    var subscriptionId: String {
        Constants.chatsSubId
    }

    func build() -> SubscriptionData {
        let sorts: [DataviewSort] = .builder {
            SearchHelper.sort(relation: .lastMessageDate, type: .desc)
        }

        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.chatDerived])
        }

        let keys: [String] = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.description.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.layout.rawValue,
            BundledPropertyKey.resolvedLayout.rawValue,
            BundledPropertyKey.type.rawValue,
            BundledPropertyKey.isDeleted.rawValue
        ]

        return .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: Constants.chatsSubId,
                filters: filters,
                keys: keys,
                noDepSubscription: true
            )
        )
    }
}
