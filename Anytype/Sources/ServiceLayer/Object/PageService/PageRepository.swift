import ProtobufMessages
import SwiftProtobuf
import Services
import AnytypeCore

protocol PageRepositoryProtocol: AnyObject {
    func createDefaultPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        templateId: String?
    ) async throws -> ObjectDetails
    
    func createPage(
        name: String,
        typeUniqueKey: ObjectTypeUniqueKey,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        templateId: String?
    ) async throws -> ObjectDetails
}

// MARK: - Default arguments
extension PageRepositoryProtocol {
    func createDefaultPage(
        name: String,
        shouldDeleteEmptyObject: Bool = false,
        shouldSelectType: Bool = false,
        shouldSelectTemplate: Bool = false,
        spaceId: String,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        try await createDefaultPage(
            name: name,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            spaceId: spaceId,
            templateId: templateId
        )
    }
}

final class PageRepository: PageRepositoryProtocol {
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let pageService: PageServiceProtocol
    
    init(objectTypeProvider: ObjectTypeProviderProtocol,
         pageService: PageServiceProtocol) {
        self.objectTypeProvider = objectTypeProvider
        self.pageService = pageService
    }
    
    func createPage(
        name: String,
        typeUniqueKey: ObjectTypeUniqueKey,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        try await pageService.createPage(
            name: name,
            typeUniqueKey: typeUniqueKey,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            spaceId: spaceId,
            templateId: templateId
        )
    }
    
    func createDefaultPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        let defaultObjectType = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
        return try await pageService.createPage(
            name: name,
            typeUniqueKey: defaultObjectType.uniqueKey,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            spaceId: spaceId,
            templateId: templateId
        )
    }
}
