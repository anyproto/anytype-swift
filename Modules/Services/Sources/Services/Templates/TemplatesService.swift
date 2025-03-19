import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

public protocol TemplatesServiceProtocol: Sendable {
    func cloneTemplate(blockId: String) async throws
    func createTemplateFromObjectType(objectTypeId: String, spaceId: String) async throws -> String
    func createTemplateFromObject(objectId: String) async throws -> String
    func deleteTemplate(templateId: String) async throws
    func setTemplateAsDefaultForType(objectTypeId: String, templateId: String) async throws
}

final class TemplatesService: TemplatesServiceProtocol {
    
    public func cloneTemplate(blockId: String) async throws {
        _ = try await ClientCommands.objectListDuplicate(.with {
            $0.objectIds = [blockId]
        }).invoke()
    }
    
    public func createTemplateFromObjectType(objectTypeId: String, spaceId: String) async throws -> String {
        let objectDetails = try await objectDetails(objectId: objectTypeId, spaceId: spaceId)
        
        let response = try await ClientCommands.objectCreate(.with {
            $0.details = .with {
                var fields = [String: Google_Protobuf_Value]()
                fields[BundledRelationKey.targetObjectType.rawValue] = objectTypeId.protobufValue
                fields[BundledRelationKey.resolvedLayout.rawValue] = objectDetails.recommendedLayout?.protobufValue ?? DetailsLayout.note.rawValue.protobufValue
                $0.fields = fields
            }
            $0.spaceID = objectDetails.spaceId
            $0.objectTypeUniqueKey = ObjectTypeUniqueKey.template.value
            $0.createTypeWidgetIfMissing = FeatureFlags.objectTypeWidgets
        }).invoke()
        
        return response.objectID
    }
    
    public func createTemplateFromObject(objectId: String) async throws -> String {
        let response = try await ClientCommands.templateCreateFromObject(.with {
            $0.contextID = objectId
        }).invoke()
        
        return response.id
    }
    
    public func deleteTemplate(templateId: String) async throws {
        _ = try await ClientCommands.objectSetIsArchived(.with {
            $0.contextID = templateId
            $0.isArchived = true
        }).invoke()
    }
    
    public func setTemplateAsDefaultForType(objectTypeId: String, templateId: String) async throws {
        _ = try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectTypeId
            
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = BundledRelationKey.defaultTemplateId.rawValue
                    $0.value = templateId.protobufValue
                }
            ]
        }).invoke()
    }
    
    // MARK: - Private
    
    private func objectDetails(objectId: String, spaceId: String) async throws -> ObjectDetails {
        let objectShow = try await ClientCommands.objectShow(.with {
            $0.contextID = objectId
            $0.objectID = objectId
            $0.spaceID = spaceId
        }).invoke()
        
        guard let details = objectShow.objectView.details.first(where: { $0.id == objectId })?.details,
              let objectDetails = try? ObjectDetails(protobufStruct: details) else {
            throw AnyUnpackError.typeMismatch
        }
        
        return objectDetails
    }
}
