import ProtobufMessages
import AnytypeCore
import SwiftProtobuf

public enum BlockServiceError: Error {
    case lastBlockIdNotFound
}

final class BlockService: BlockServiceProtocol {
    
    public func add(contextId: String, targetId: String, info: BlockInformation, position: BlockPosition) async throws -> String {
        guard let block = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("addActionBlockIsNotParsed")
            throw CommonError.undefined
        }

        let response = try await ClientCommands.blockCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.block = block
            $0.position = position.asMiddleware
        }).invoke()
        
        return response.blockID
    }
    
    public func addFirstBlock(contextId: String, info: BlockInformation) async throws -> String {
        let headerBlockId = "header"
        return try await add(contextId: contextId, targetId: headerBlockId, info: info, position: .bottom)
    }
    
    public func delete(contextId: String, blockIds: [String]) async throws {
        try await ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        }).invoke()
    }

    public func duplicate(contextId: String, targetId: String, blockIds: [String], position: BlockPosition) async throws {
        try await ClientCommands.blockListDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockIds = blockIds
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func move(
        contextId: String,
        blockIds: [String],
        targetContextID: String,
        dropTargetID: String,
        position: BlockPosition
    ) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
            $0.targetContextID = targetContextID
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }   
    
    public func setBlockColor(objectId: String, blockIds: [String], color: MiddlewareColor) async throws {
        try await ClientCommands.blockTextListSetColor(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.color = color.rawValue
        }).invoke()
    }
    
    public func setFields(objectId: String, blockId: String, fields: BlockFields) async throws {
        let fieldsRequest = Anytype_Rpc.Block.ListSetFields.Request.BlockField.with {
            $0.blockID = blockId
            $0.fields = .with {
                $0.fields = fields
            }
        }
        try await ClientCommands.blockListSetFields(.with {
            $0.contextID = objectId
            $0.blockFields = [fieldsRequest]
        }).invoke()
    }

    public func changeMarkup(
        objectId: String,
        blockIds: [String],
        markType: MarkupType
    ) async throws {
        guard let mark = markType.asMiddleware else { return }
        try await ClientCommands.blockTextListSetMark(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.mark = mark
        }).invoke()
    }

    public func setBackgroundColor(objectId: String, blockIds: [String], color: MiddlewareColor) async throws {
        try await ClientCommands.blockListSetBackgroundColor(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.color = color.rawValue
        }).invoke()
    }

    public func setAlign(objectId: String, blockIds: [String], alignment: LayoutAlignment) async throws {
        try await ClientCommands.blockListSetAlign(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.align = alignment
        }).invoke()
    }

    public func replace(objectId: String, blockIds: [String], targetId: String) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.targetContextID = objectId
            $0.dropTargetID = targetId
            $0.position = .replace
        }).invoke()
    }
    
    public func move(objectId: String, blockId: String, targetId: String, position: Anytype_Model_Block.Position) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = objectId
            $0.blockIds = [blockId]
            $0.targetContextID = objectId
            $0.dropTargetID = targetId
            $0.position = position
        }).invoke()
    }
    
    public func moveToPage(objectId: String, blockId: String, pageId: String) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = objectId
            $0.blockIds = [blockId]
            $0.targetContextID = pageId
            $0.dropTargetID = ""
            $0.position = .bottom
        }).invoke()
    }

    public func setLinkAppearance(objectId: String, blockIds: [String], appearance: BlockLink.Appearance) async throws {
        try await ClientCommands.blockLinkListSetAppearance(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.iconSize = appearance.iconSize.asMiddleware
            $0.cardStyle = appearance.cardStyle.asMiddleware
            $0.description_p = appearance.description.asMiddleware
            $0.relations = appearance.relations.map(\.rawValue)
        }).invoke()
    }
    
    public func lastBlockId(from objectId: String) async throws -> String {
        let objectShow = try await ClientCommands.objectShow(.with {
            $0.contextID = objectId
            $0.objectID = objectId
        }).invoke()
        

        guard let lastBlockId = objectShow.objectView.blocks.first(where: { $0.id == objectId} )?.childrenIds.last else {
            throw BlockServiceError.lastBlockIdNotFound
        }
    
        return lastBlockId
    }
    
    public func convertChildrenToPages(contextId: String, blocksIds: [String], typeUniqueKey: ObjectTypeUniqueKey) async throws -> [String] {
        let response = try await ClientCommands.blockListConvertToObjects(.with {
            $0.contextID = contextId
            $0.blockIds = blocksIds
            $0.objectTypeUniqueKey = typeUniqueKey.value
        }).invoke()
        
        return response.linkIds
    }
    
    public func createBlockLink(
        contextId: String,
        targetId: String,
        spaceId: String,
        details: [BundledDetails],
        typeUniqueKey: ObjectTypeUniqueKey,
        position: BlockPosition,
        templateId: String
    ) async throws -> String {
        let protobufDetails = details.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            Anytype_Model_InternalFlag.with { $0.value = .editorSelectTemplate }
        }
        
        let response = try await ClientCommands.blockLinkCreateWithObject(.with {
            $0.contextID = contextId
            $0.details = protobufStruct
            $0.templateID = templateId
            $0.targetID = targetId
            $0.position = position.asMiddleware
            $0.internalFlags = internalFlags
            $0.spaceID = spaceId
            $0.objectTypeUniqueKey = typeUniqueKey.value
        }).invoke()
        
        return response.targetID
    }

}

private extension MarkupType {
    var asMiddleware: Anytype_Model_Block.Content.Text.Mark? {
        switch self {
        case .bold:
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .bold, param: "")
        case .italic:
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .italic, param: "")
        case .keyboard:
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .keyboard, param: "")
        case .strikethrough:
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .strikethrough, param: "")
        case .underscored:
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .underscored, param: "")
        case let .textColor(color):
            let param = color.rawValue
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .textColor, param: param)
        case let .backgroundColor(color):
            let param = color.rawValue
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .backgroundColor, param: param)
        case let .link(url):
            let param = url?.absoluteString ?? ""
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .link, param: param)
        case let .linkToObject(blockId):
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .object, param: blockId ?? "")
        case let .mention(mentionData):
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .mention, param: mentionData.id)
        case let .emoji(emoji):
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .emoji, param: emoji.value)
        }
    }
}

private extension Anytype_Model_Block.Content.Text.Mark {
    init(range: Anytype_Model_Range, type: Anytype_Model_Block.Content.Text.Mark.TypeEnum, param: String) {
        self.init()
        self.range = range
        self.type = type
        self.param = param
    }
}
