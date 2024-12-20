import Foundation
import Services
import AnytypeCore

final class DetailsService: DetailsServiceProtocol, Sendable {
    
    private let service: any ObjectActionsServiceProtocol = Container.shared.objectActionsService()
    private let fileService: any FileActionsServiceProtocol = Container.shared.fileActionsService()
    
    // MARK: - DetailsServiceProtocol

    func updateBundledDetails(objectId: String, bundledDetails: [BundledDetails]) async throws {
        try await service.updateBundledDetails(contextID: objectId, details: bundledDetails)
    }
    
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws {
        try await service.updateDetails(contextId: contextId, relationKey: relationKey, value: value)
    }

    func setLayout(objectId: String, detailsLayout: DetailsLayout) async throws {
        try await service.updateLayout(contextID: objectId, value: detailsLayout.rawValue)
    }
    
    func setCover(objectId: String, spaceId: String, source: FileUploadingSource) async throws {
        let data = try await fileService.createFileData(source: source)
        let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
        try await setCover(objectId: objectId, imageObjectId: fileDetails.id)
    }
    
    func setCover(objectId: String, imageObjectId: String) async throws {
        try await updateBundledDetails(
            objectId: objectId,
            bundledDetails: [.coverType(CoverType.uploadedImage), .coverId(imageObjectId)]
        )
    }
}
