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
    func updateBundledDetails(_ bundledDetails: [BundledDetails]) async throws {
        try await service.updateBundledDetails(contextID: objectId, details: bundledDetails)
    }
    
    func updateBundledDetails(contextID: String, bundledDetails: [BundledDetails]) async throws {
        try await service.updateBundledDetails(contextID: contextID, details: bundledDetails)
    }
    
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws {
        try await service.updateDetails(contextId: contextId, relationKey: relationKey, value: value)
    }

    func setLayout(_ detailsLayout: DetailsLayout) async throws {
        try await service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
    func setCover(spaceId: String, source: FileUploadingSource) async throws {
        let data = try await fileService.createFileData(source: source)
        let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
        try await setCover(imageObjectId: fileDetails.id)
    }
    
    func setCover(imageObjectId: String) async throws {
        try await updateBundledDetails([.coverType(CoverType.uploadedImage), .coverId(imageObjectId)])
    }
}
