import Services
import AnytypeCore

protocol DetailsServiceProtocol {
        
    func updateBundledDetails(_ bundledDetails: [BundledDetails]) async throws
    func updateBundledDetails(contextID: String, bundledDetails: [BundledDetails]) async throws
    func setLayout(_ detailsLayout: DetailsLayout) async throws
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws
    
    func setCover(spaceId: String, source: FileUploadingSource) async throws
    func setCover(imageHash: Hash) async throws
    func setObjectIcon(spaceId: String, source: FileUploadingSource) async throws
}
