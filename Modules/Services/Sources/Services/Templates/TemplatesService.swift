import ProtobufMessages
import SwiftProtobuf

public protocol TemplatesServiceProtocol {
    func cloneTemplate(blockId: BlockId) async throws
    func createTemplateFromObjectType(objectTypeId: BlockId) async throws -> BlockId
    func createTemplateFromObject(objectId: BlockId) async throws -> BlockId
    func deleteTemplate(templateId: BlockId) async throws
    func setTemplateAsDefaultForType(objectTypeId: BlockId, templateId: BlockId) async throws
}

public final class TemplatesService: TemplatesServiceProtocol {
    public init() {}
    
    public func cloneTemplate(blockId: BlockId) async throws {
        _ = try await ClientCommands.objectListDuplicate(.with {
            $0.objectIds = [blockId]
        }).invoke()
    }
    
    public func createTemplateFromObjectType(objectTypeId: BlockId) async throws -> BlockId {
        let objectDetails = try await objectDetails(objectId: objectTypeId)
        
        let response = try await ClientCommands.objectCreate(.with {
            $0.details = .with {
                var fields = [String: Google_Protobuf_Value]()
                fields[BundledRelationKey.targetObjectType.rawValue] = objectTypeId.protobufValue
                fields[BundledRelationKey.layout.rawValue] = objectDetails.recommendedLayout?.protobufValue ?? DetailsLayout.note.rawValue.protobufValue
                $0.fields = fields
            }
            $0.spaceID = objectDetails.spaceId
            $0.objectTypeUniqueKey = ObjectTypeUniqueKey.template.value
        }).invoke()
        
        return response.objectID
    }
    
    public func createTemplateFromObject(objectId: BlockId) async throws -> BlockId {
        let response = try await ClientCommands.templateCreateFromObject(.with {
            $0.contextID = objectId
        }).invoke()
        
        return response.id
    }
    
    public func deleteTemplate(templateId: BlockId) async throws {
        _ = try await ClientCommands.objectSetIsArchived(.with {
            $0.contextID = templateId
            $0.isArchived = true
        }).invoke()
    }
    
    public func setTemplateAsDefaultForType(objectTypeId: BlockId, templateId: BlockId) async throws {
        _ = try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectTypeId
            
            $0.details = [
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = BundledRelationKey.defaultTemplateId.rawValue
                    $0.value = templateId.protobufValue
                }
            ]
        }).invoke()
    }
    
    // MARK: - Private
    
    private func objectDetails(objectId: BlockId) async throws -> ObjectDetails {
        let objectShow = try await ClientCommands.objectShow(.with {
            $0.contextID = objectId
            $0.objectID = objectId
        }).invoke()
        
        guard let details = objectShow.objectView.details.first(where: { $0.id == objectId })?.details,
              let objectDetails = try? ObjectDetails(protobufStruct: details) else {
            throw AnyUnpackError.typeMismatch
        }
        
        return objectDetails
    }
}
