import Foundation
import BlocksModels
import SwiftProtobuf

final class DetailsService {
    
    private let service = ObjectActionsService()

    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
}

extension DetailsService: DetailsServiceProtocol {
    
    func updateBundledDetails(_ bundledDpdates: [BundledDetails]) {
        updateDetails(bundledDpdates.map { $0.asDetailsUpdate })
    }
    
    func updateDetails(_ updates: [DetailsUpdate]) {
        service.updateDetails(contextID: objectId, updates: updates)
    }

    func setLayout(_ detailsLayout: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
}
