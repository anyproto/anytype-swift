import Foundation
import BlocksModels
import SwiftProtobuf

final class DetailsService {
    
    private let service: ObjectActionsServiceProtocol

    private let objectId: String
        
    init(objectId: String, service: ObjectActionsServiceProtocol) {
        self.objectId = objectId
        self.service = service
    }
    
}

extension DetailsService: DetailsServiceProtocol {
    
    func updateBundledDetails(_ bundledDpdates: [BundledDetails]) {
        service.updateBundledDetails(contextID: objectId, details: bundledDpdates)
    }

    func setLayout(_ detailsLayout: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
}
