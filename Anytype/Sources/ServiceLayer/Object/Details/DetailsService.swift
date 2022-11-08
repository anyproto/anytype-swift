import Foundation
import BlocksModels
import AnytypeCore

final class DetailsService {
    
    private let service: ObjectActionsServiceProtocol

    private let objectId: BlockId
        
    init(objectId: BlockId, service: ObjectActionsServiceProtocol) {
        self.objectId = objectId
        self.service = service
    }
    
}

extension DetailsService: DetailsServiceProtocol {
    
    func updateBundledDetails(_ bundledDpdates: [BundledDetails]) {
        service.updateBundledDetails(contextID: objectId, details: bundledDpdates)
    }
    
    func updateBundledDetails(contextID: String, bundledDpdates: [BundledDetails]) {
        service.updateBundledDetails(contextID: contextID, details: bundledDpdates)
    }
    
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) {
        service.updateDetails(contextId: contextId, relationKey: relationKey, value: value)
    }

    func setLayout(_ detailsLayout: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
}
