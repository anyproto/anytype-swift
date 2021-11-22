import Foundation
import BlocksModels
import Combine
import SwiftProtobuf

// TODO: rething ObjectRawDetails/RelationMetadataKey
final class DetailsService {
    
    private let service = ObjectActionsService()

    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
}

extension DetailsService: DetailsServiceProtocol {
    
    func update(details: ObjectRawDetails) {
        service.setDetails(contextID: objectId, details: details)
    }
    
    func updateRelationValue(key: String, value: Google_Protobuf_Value) {
        service.setRelationValue(contextID: objectId, key: key, value: value)
    }
    
    func updateDetails(_ updates: [DetailsUpdate]) {
        service.updateDetails(contextID: objectId, updates: updates)
    }

    func setLayout(_ detailsLayout: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
}
