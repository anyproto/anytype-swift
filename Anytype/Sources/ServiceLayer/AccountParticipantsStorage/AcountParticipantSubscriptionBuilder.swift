import Foundation
import Services


final class AcountParticipantSubscriptionBuilder {
    
    func build(accountId: String, subId: String) -> SubscriptionData {
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.identity(accountId)
            SearchHelper.layoutFilter([.participant])
        }
        
        let searchData: SubscriptionData = .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: subId,
                filters: filters,
                keys: Participant.subscriptionKeys.map { $0.rawValue },
                noDepSubscription: true
            )
        )
        
        return searchData
    }
}
