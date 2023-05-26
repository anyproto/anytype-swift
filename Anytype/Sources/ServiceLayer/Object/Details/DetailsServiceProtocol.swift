import Services
import AnytypeCore

protocol DetailsServiceProtocol {
        
    func updateBundledDetails(_ bundledDetails: [BundledDetails])
    func updateBundledDetails(_ bundledDetails: [BundledDetails]) async throws
    func updateBundledDetails(contextID: String, bundledDetails: [BundledDetails])
    func setLayout(_ detailsLayout: DetailsLayout)
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue)
    
    func setCover(source: FileUploadingSource) async throws
    func setCover(imageHash: Hash) async throws
    func setObjectIcon(source: FileUploadingSource) async throws
}
