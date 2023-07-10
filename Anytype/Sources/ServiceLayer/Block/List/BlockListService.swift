import Foundation
import Combine
import Services
import UIKit
import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

class BlockListService: BlockListServiceProtocol {
    func setBlockColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) {
        _ = try? ClientCommands.blockTextListSetColor(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.color = color.rawValue
        }).invoke()
    }
    
    func setFields(objectId: BlockId, blockId: BlockId, fields: BlockFields) {
        let fieldsRequest = Anytype_Rpc.Block.ListSetFields.Request.BlockField.with {
            $0.blockID = blockId
            $0.fields = .with {
                $0.fields = fields
            }
        }
        _ = try? ClientCommands.blockListSetFields(.with {
            $0.contextID = objectId
            $0.blockFields = [fieldsRequest]
        }).invoke()
    }

    func changeMarkup(
        objectId: BlockId,
        blockIds: [BlockId],
        markType: MarkupType
    ) async throws {
        guard let mark = markType.asMiddleware else { return }
        try await ClientCommands.blockTextListSetMark(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.mark = mark
        }).invoke()
    }

    func setBackgroundColor(objectId: BlockId, blockIds: [BlockId], color: MiddlewareColor) async throws {
        AnytypeAnalytics.instance().logChangeBlockBackground(color: color)
        
        try await ClientCommands.blockListSetBackgroundColor(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.color = color.rawValue
        }).invoke()
    }

    func setAlign(objectId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) {
        AnytypeAnalytics.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)

        _ = try? ClientCommands.blockListSetAlign(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.align = alignment.asMiddleware
        }).invoke()
    }

    func replace(objectId: BlockId, blockIds: [BlockId], targetId: BlockId) {
        _ = try? ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.targetContextID = objectId
            $0.dropTargetID = targetId
            $0.position = .replace
        }).invoke()
    }
    
    func move(objectId: BlockId, blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position) {
        _ = try? ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = objectId
            $0.blockIds = [blockId]
            $0.targetContextID = objectId
            $0.dropTargetID = targetId
            $0.position = position
        }).invoke()
    }
    
    func moveToPage(objectId: BlockId, blockId: BlockId, pageId: BlockId) {
        _ = try? ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = objectId
            $0.blockIds = [blockId]
            $0.targetContextID = pageId
            $0.dropTargetID = ""
            $0.position = .bottom
        }).invoke()
    }

    func setLinkAppearance(objectId: BlockId, blockIds: [BlockId], appearance: BlockLink.Appearance) async throws {
        try await ClientCommands.blockLinkListSetAppearance(.with {
            $0.contextID = objectId
            $0.blockIds = blockIds
            $0.iconSize = appearance.iconSize.asMiddleware
            $0.cardStyle = appearance.cardStyle.asMiddleware
            $0.description_p = appearance.description.asMiddleware
            $0.relations = appearance.relations.map(\.rawValue)
        }).invoke()
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
            let param = color.middlewareString(background: false) ?? ""
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .textColor, param: param)
        case let .backgroundColor(color):
            let param = color.middlewareString(background: true) ?? ""
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .backgroundColor, param: param)
        case let .link(url):
            let param = url?.absoluteString ?? ""
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .link, param: param)
        case let .linkToObject(blockId):
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .object, param: blockId ?? "")
        case let .mention(mentionData):
            return Anytype_Model_Block.Content.Text.Mark(range: .init(), type: .mention, param: mentionData.blockId)
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
