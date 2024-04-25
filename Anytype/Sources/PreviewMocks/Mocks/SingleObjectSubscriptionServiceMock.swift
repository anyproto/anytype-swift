import Foundation
import Services

final class SingleObjectSubscriptionServiceMock: SingleObjectSubscriptionServiceProtocol {
    
    static let shared = SingleObjectSubscriptionServiceMock()
    
    var objectDetails: ObjectDetails?
    
    func startSubscription(
        subId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    ) async {
        if let objectDetails {
            dataHandler(objectDetails)
        }
    }
    
    func stopSubscription(subId: String) async {}
}
