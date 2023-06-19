import Foundation
import Services
import AnytypeCore

final class DetailsService {
    
    private let objectId: BlockId
    private let service: ObjectActionsServiceProtocol
    private let fileService: FileActionsServiceProtocol
        
    init(objectId: BlockId, service: ObjectActionsServiceProtocol, fileService: FileActionsServiceProtocol) {
        self.objectId = objectId
        self.service = service
        self.fileService = fileService
    }
}

extension DetailsService: DetailsServiceProtocol {
    
    func updateBundledDetails(_ bundledDetails: [BundledDetails]) {
        service.updateBundledDetails(contextID: objectId, details: bundledDetails)
    }
    
    func updateBundledDetails(_ bundledDetails: [BundledDetails]) async throws {
        try await service.updateBundledDetails(contextID: objectId, details: bundledDetails)
    }
    
    func updateBundledDetails(contextID: String, bundledDetails: [BundledDetails]) {
        service.updateBundledDetails(contextID: contextID, details: bundledDetails)
    }
    
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) {
        service.updateDetails(contextId: contextId, relationKey: relationKey, value: value)
    }

    func setLayout(_ detailsLayout: DetailsLayout) {
        service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
    func setCover(source: FileUploadingSource) async throws {
        EventsBunch(
            contextId: objectId,
            localEvents: [.header(.coverUploading(.bundleImagePath("")))]
        ).send()
        let data = try await fileService.createFileData(source: source)
        EventsBunch(
            contextId: objectId,
            localEvents: [.header(.coverUploading(.bundleImagePath(data.path)))]
        ).send()
        let imageHash = try await fileService.uploadImage(data: data)
        try await setCover(imageHash: imageHash)
    }
    
    func setCover(imageHash: Hash) async throws {
        try await updateBundledDetails([.coverType(CoverType.uploadedImage), .coverId(imageHash.value)])
    }
    
    func setObjectIcon(source: FileUploadingSource) async throws {
        EventsBunch(
            contextId: objectId,
            localEvents: [.header(.iconUploading(""))]
        ).send()
        let data = try await fileService.createFileData(source: source)
        EventsBunch(
            contextId: objectId,
            localEvents: [.header(.iconUploading(data.path))]
        ).send()
        let imageHash = try await fileService.uploadImage(data: data)
        try await updateBundledDetails([.iconEmoji(""), .iconImageHash(imageHash)])
    }
}
