import ProtobufMessages
import SwiftProtobuf

public protocol PageServiceProtocol: AnyObject {
    func createPage(
        name: String,
        type: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String?
    ) async throws -> ObjectDetails
}

public final class PageService: PageServiceProtocol {
    public init() {}
    
    public func createPage(
        name: String,
        type: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String? = nil
    ) async throws -> ObjectDetails {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue,
                BundledRelationKey.type.rawValue: type.protobufValue
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
        }).invoke()
        
        return try response.details.toDetails()
    }
}
