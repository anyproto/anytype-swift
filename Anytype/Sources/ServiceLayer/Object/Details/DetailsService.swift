import Foundation
import BlocksModels
import SwiftProtobuf
import AnytypeCore

final class DetailsService {
    
    private let service: ObjectActionsServiceProtocol

    private let objectId: AnytypeId
        
    init(objectId: AnytypeId, service: ObjectActionsServiceProtocol) {
        self.objectId = objectId
        self.service = service
    }
    
}

extension DetailsService: DetailsServiceProtocol {
    
    func updateBundledDetails(_ bundledDpdates: [BundledDetails]) {
        service.updateBundledDetails(contextID: objectId.value, details: bundledDpdates)
    }

    func setLayout(_ detailsLayout: DetailsLayout) {
        service.updateLayout(contextID: objectId.value, value: detailsLayout.rawValue)
    }
    
}
