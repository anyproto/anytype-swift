import ProtobufMessages
import SwiftProtobuf

public protocol TemplatesServiceProtocol {
    func cloneTemplate(blockId: BlockId) async throws
    func createTemplateFromObjectType(objectTypeId: BlockId) async throws -> BlockId
    func deleteTemplate(templateId: BlockId) async throws
}

public final class TemplatesService: TemplatesServiceProtocol {
    public init() {}
    
    public func cloneTemplate(blockId: BlockId) async throws {
        _ = try await ClientCommands.objectListDuplicate(.with {
            $0.objectIds = [blockId]
        }).invoke()
    }
    
    public func createTemplateFromObjectType(objectTypeId: BlockId) async throws -> BlockId {
        let objectShow = try await ClientCommands.objectShow(.with {
            $0.contextID = objectTypeId
            $0.objectID = objectTypeId
        }).invoke()
        
        guard let details = objectShow.objectView.details.first(where: { $0.id == objectTypeId })?.details,
              let objectDetails = try? ObjectDetails(protobufStruct: details) else {
            throw AnyUnpackError.typeMismatch
        }
        
        let response = try await ClientCommands.objectCreate(.with {
            $0.details = .with {
                var fields = [String: Google_Protobuf_Value]()
                fields[BundledRelationKey.targetObjectType.rawValue] = objectTypeId.protobufValue
                fields[BundledRelationKey.type.rawValue] = ObjectTypeId.BundledTypeId.template.rawValue.protobufValue
                fields[BundledRelationKey.layout.rawValue] = objectDetails.recommendedLayout?.protobufValue ?? DetailsLayout.note.rawValue.protobufValue
                $0.fields = fields
            }
        }).invoke()
        
        return response.objectID
    }
    
    public func deleteTemplate(templateId: BlockId) async throws {
        _ = try await ClientCommands.objectSetIsArchived(.with {
            $0.contextID = templateId
            $0.isArchived = true
        }).invoke()
    }
}
