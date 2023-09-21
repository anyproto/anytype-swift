import ProtobufMessages
import SwiftProtobuf
import Services

protocol PageRepositoryProtocol: AnyObject {
    func createDefaultPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String?
    ) async throws -> ObjectDetails
    
    func createPage(
        name: String,
        type: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
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
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        try await createDefaultPage(
            name: name,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
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
        type: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        try await pageService.createPage(
            name: name,
            type: type,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            templateId: templateId
        )
    }
    
    func createDefaultPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        try await pageService.createPage(
            name: name,
            type: objectTypeProvider.defaultObjectType.id,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            templateId: templateId
        )
    }
}
