import Foundation
import BlocksModels
import Combine

final class ObjectDetailsService {
    
    private let service = ObjectActionsService()

    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
    func update(details: ObjectRawDetails) {
        service.setDetails(contextID: objectId, details: details)
    }

    func updateLayout(_ layoutDetails: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: layoutDetails.rawValue)
    }
}
