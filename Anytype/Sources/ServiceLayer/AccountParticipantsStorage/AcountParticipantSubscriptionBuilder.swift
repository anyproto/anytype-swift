import Foundation
import Services

final class AcountParticipantSubscriptionBuilder: MultispaceSubscriptionDataBuilderProtocol {
    
    private let profileObjectId: String
    
    init(profileObjectId: String) {
        self.profileObjectId = profileObjectId
    }
    
    func build(spaceId: String, subId: String) -> SubscriptionData {
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.identityProfileLink(profileObjectId)
            SearchHelper.layoutFilter([.participant])
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subId,
                spaceId: spaceId,
                filters: filters,
                limit: 0,
                keys: Participant.subscriptionKeys.map { $0.rawValue },
                noDepSubscription: true
            )
        )
        
        return searchData
    }
}
