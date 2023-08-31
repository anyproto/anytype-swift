import ProtobufMessages
import SwiftProtobuf
import Services
import AnytypeCore

protocol PageServiceProtocol: AnyObject {
    func createPage(
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

// MARK: - Default argumentsf
extension PageServiceProtocol {
    func createPage(
        name: String,
        shouldDeleteEmptyObject: Bool = false,
        shouldSelectType: Bool = false,
        shouldSelectTemplate: Bool = false,
        spaceId: String,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        try await createPage(
            name: name,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            spaceId: spaceId,
            templateId: templateId
        )
    }
}

final class PageService: PageServiceProtocol {
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(objectTypeProvider: ObjectTypeProviderProtocol) {
        self.objectTypeProvider = objectTypeProvider
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
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue
            ]
        )
        
        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            if shouldDeleteEmptyObject {
                Anytype_Model_InternalFlag.with { $0.value = .editorDeleteEmpty }
            }
            if shouldSelectType {
                Anytype_Model_InternalFlag.with { $0.value = .editorSelectType }
            }
            if shouldSelectTemplate {
                Anytype_Model_InternalFlag.with { $0.value = .editorSelectTemplate }
            }
        }
        
        let response = try await ClientCommands.objectCreate(.with {
            $0.details = details
            $0.internalFlags = internalFlags
            $0.templateID = templateId ?? ""
            $0.spaceID = spaceId
            $0.objectTypeUniqueKey = typeUniqueKey.value
        }).invoke()
        
        return try response.details.toDetails()
    }
    
    func createPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        let defaultObjectType = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
        return try await createPage(
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
