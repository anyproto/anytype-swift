import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

class BlockListService: BlockListServiceProtocol {
    private let contextId: BlockId
    init(contextId: BlockId) {
        self.contextId = contextId
    }
    
    func setBlockColor(blockIds: [BlockId], color: MiddlewareColor) {
        Anytype_Rpc.BlockText.ListSetColor.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func setFields(fields: [Anytype_Rpc.Block.ListSetFields.Request.BlockField]) {
        Anytype_Rpc.Block.ListSetFields.Service
            .invoke(contextID: contextId, blockFields: fields)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func changeMarkup(
        blockIds: [BlockId],
        markType: MarkupType
    ) {
        guard let mark = markType.asMiddleware else { return }
        Anytype_Rpc.BlockText.ListSetMark.Service
            .invoke(contextID: contextId, blockIds: blockIds, mark: mark
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListSetBackgroundColor)

        Anytype_Rpc.Block.ListSetBackgroundColor.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setAlign(blockIds: [BlockId], alignment: LayoutAlignment) {
        AnytypeAnalytics.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)

        Anytype_Rpc.Block.ListSetAlign.Service
            .invoke(contextID: contextId, blockIds: blockIds, align: alignment.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setDivStyle(blockIds: [BlockId], style: BlockDivider.Style) {
        Anytype_Rpc.BlockDiv.ListSetStyle.Service
            .invoke(contextID: contextId, blockIds: blockIds, style: style.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func replace(blockIds: [BlockId], targetId: BlockId) {
        Anytype_Rpc.Block.ListMoveToExistingObject.Service.invoke(
            contextID: contextId,
            blockIds: blockIds,
            targetContextID: contextId,
            dropTargetID: targetId,
            position: .replace
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func move(blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position) {
        Anytype_Rpc.Block.ListMoveToExistingObject.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: contextId,
            dropTargetID: targetId,
            position: position
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        Anytype_Rpc.Block.ListMoveToExistingObject.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: pageId,
            dropTargetID: "",
            position: .bottom
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setLinkAppearance(blockIds: [BlockId], appearance: BlockLink.Appearance) {
        Anytype_Rpc.BlockLink.ListSetAppearance.Service.invoke(
            contextID: contextId,
            blockIds: blockIds,
            iconSize: appearance.iconSize.asMiddleware,
            cardStyle: appearance.cardStyle.asMiddleware,
            description_p: appearance.description.asMiddleware,
            relations: appearance.relations.map(\.rawValue)
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
}

private extension MarkupType {
    var asMiddleware: Anytype_Model_Block.Content.Text.Mark? {
        switch self {
        case .bold:
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .bold, param: "")
        case .italic:
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .italic, param: "")
        case .keyboard:
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .keyboard, param: "")
        case .strikethrough:
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .strikethrough, param: "")
        case .underscored:
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .underscored, param: "")
        case let .textColor(color):
            let param = color.middlewareString(background: false) ?? ""
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .textColor, param: param)
        case let .backgroundColor(color):
            let param = color.middlewareString(background: true) ?? ""
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .backgroundColor, param: param)
        case let .link(url):
            let param = url?.absoluteString ?? ""
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .link, param: param)
        case let .linkToObject(blockId):
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .object, param: blockId ?? "")
        case let .mention(mentionData):
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .mention, param: mentionData.blockId)
        case let .emoji(emoji):
            return Anytype_Model_Block.Content.Text.Mark.init(range: .init(), type: .emoji, param: emoji.value)
        }
    }
}
