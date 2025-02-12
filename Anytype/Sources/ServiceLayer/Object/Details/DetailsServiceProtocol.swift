import Services
import AnytypeCore

protocol DetailsServiceProtocol: Sendable {
        
    func updateBundledDetails(objectId: String, bundledDetails: [BundledDetails]) async throws
    func setLayout(objectId: String, detailsLayout: DetailsLayout) async throws
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws
    
    func setCover(objectId: String, spaceId: String, source: FileUploadingSource) async throws
    func setCover(objectId: String, imageObjectId: String) async throws
}
