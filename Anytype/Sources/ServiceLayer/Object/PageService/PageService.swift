import ProtobufMessages
import SwiftProtobuf
import BlocksModels

protocol PageServiceProtocol: AnyObject {
    func createPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String?
    ) -> BlockId?
}

// MARK: - Default argumentsf
extension PageServiceProtocol {
    func createPage(
        name: String,
        shouldDeleteEmptyObject: Bool = false,
        shouldSelectType: Bool = false,
        shouldSelectTemplate: Bool = false,
        templateId: String? = nil
    ) -> BlockId? {
        createPage(
            name: name,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: shouldSelectType,
            shouldSelectTemplate: shouldSelectTemplate,
            templateId: templateId
        )
    }
}

final class PageService: PageServiceProtocol {
    func createPage(
        name: String,
        shouldDeleteEmptyObject: Bool,
        shouldSelectType: Bool,
        shouldSelectTemplate: Bool,
        templateId: String? = nil
    ) -> BlockId? {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue,
                BundledRelationKey.type.rawValue: ObjectTypeProvider.shared.defaultObjectType.id.protobufValue
            ]
        )
        
        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            if shouldDeleteEmptyObject {
                Anytype_Model_InternalFlag(value: .editorDeleteEmpty)
            }
            if shouldSelectType {
                Anytype_Model_InternalFlag(value: .editorSelectType)
            }
            if shouldSelectTemplate {
                Anytype_Model_InternalFlag(value: .editorSelectTemplate)
            }
        }
        
        let response = Anytype_Rpc.Object.Create.Service
            .invocation(details: details, internalFlags: internalFlags, templateID: templateId ?? "")
            .invoke()
            .getValue(domain: .pageService)
        
        guard let response else {
            return nil
        }
        
        EventsBunch(event: response.event).send()
        return response.objectID
    }
}
