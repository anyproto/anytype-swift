import Foundation
import BlocksModels
import Combine
import SwiftProtobuf

// TODO: rething ObjectRawDetails/RelationMetadataKey
final class ObjectDetailsService {
    
    private let service = ObjectActionsService()

    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
    func update(details: ObjectRawDetails) {
        service.setDetails(contextID: objectId, details: details)
    }
    
    func updateRelationValue(key: String, value: Google_Protobuf_Value) {
        service.setRelationValue(contextID: objectId, key: key, value: value)
    }

    func updateLayout(_ layoutDetails: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: layoutDetails.rawValue)
    }
}
