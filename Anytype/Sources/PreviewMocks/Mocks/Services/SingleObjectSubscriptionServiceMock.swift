import Foundation
import Services

final class SingleObjectSubscriptionServiceMock: SingleObjectSubscriptionServiceProtocol, @unchecked Sendable {
    
    static let shared = SingleObjectSubscriptionServiceMock()
    
    var objectDetails: ObjectDetails?
    
    func startSubscription(
        subId: String,
        spaceId: String,
        objectId: String,
        additionalKeys: [BundledPropertyKey],
        dataHandler: @escaping @Sendable (ObjectDetails) async -> Void
    ) async {
        if let objectDetails {
            await dataHandler(objectDetails)
        }
    }
    
    func stopSubscription(subId: String) async {}
}
