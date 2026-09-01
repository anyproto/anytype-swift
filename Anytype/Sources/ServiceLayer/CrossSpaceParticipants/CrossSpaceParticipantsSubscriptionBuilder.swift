import Foundation
import Services
import AnytypeCore

protocol CrossSpaceParticipantsSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build() -> SubscriptionData
}

final class CrossSpaceParticipantsSubscriptionBuilder: CrossSpaceParticipantsSubscriptionBuilderProtocol {

    private enum Constants {
        static let participantsSubId = "SubscriptionId.CrossSpaceParticipants"
    }

    var subscriptionId: String {
        Constants.participantsSubId
    }

    func build() -> SubscriptionData {
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.participant])
        }

        return .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: Constants.participantsSubId,
                filters: filters,
                keys: Participant.subscriptionKeys.map { $0.rawValue },
                noDepSubscription: true
            )
        )
    }
}
