import Foundation
import Services
import AnytypeCore

protocol CrossSpaceTypesSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build() -> SubscriptionData
}

final class CrossSpaceTypesSubscriptionBuilder: CrossSpaceTypesSubscriptionBuilderProtocol {

    private enum Constants {
        static let typesSubId = "SubscriptionId.CrossSpaceTypes"
    }

    var subscriptionId: String {
        Constants.typesSubId
    }

    func build() -> SubscriptionData {
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.objectType])
        }

        let keys: [String] = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.pluralName.rawValue,
            BundledPropertyKey.uniqueKey.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.resolvedLayout.rawValue,
            BundledPropertyKey.recommendedLayout.rawValue,
            BundledPropertyKey.iconEmoji.rawValue,
            BundledPropertyKey.iconName.rawValue,
            // iconName without iconOption renders every type in the default
            // color - the icon builder needs both
            BundledPropertyKey.iconOption.rawValue,
            BundledPropertyKey.isHidden.rawValue,
            BundledPropertyKey.isDeleted.rawValue,
            BundledPropertyKey.lastUsedDate.rawValue
        ]

        return .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: Constants.typesSubId,
                filters: filters,
                keys: keys,
                noDepSubscription: true
            )
        )
    }
}
