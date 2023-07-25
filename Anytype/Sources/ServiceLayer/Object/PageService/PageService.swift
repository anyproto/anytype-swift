import ProtobufMessages
import SwiftProtobuf
import Services

protocol PageServiceProtocol: AnyObject {
    func createPage(
        name: String,
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
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        spaceId: String,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue,
                BundledRelationKey.type.rawValue: objectTypeProvider.defaultObjectType.id.protobufValue
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
        }).invoke()
        
        return try response.details.toDetails()
    }
}
