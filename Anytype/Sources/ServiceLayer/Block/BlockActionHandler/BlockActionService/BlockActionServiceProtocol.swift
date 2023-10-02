import Services
import UIKit
import ProtobufMessages
import AnytypeCore

protocol BlockActionServiceProtocol {

    func upload(blockId: BlockId, filePath: String) async throws
    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    func turnIntoPage(blockId: BlockId, spaceId: String) async throws -> BlockId?
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool)
    func addChild(info: BlockInformation, parentId: BlockId)
    func delete(blockIds: [BlockId])
    func createPage(targetId: BlockId, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, position: BlockPosition, templateId: String) async throws -> BlockId
    func split(
        _ string: NSAttributedString,
        blockId: BlockId,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        range: NSRange,
        newBlockContentType: BlockText.Style
    )
    
    func bookmarkFetch(blockId: BlockId, url: AnytypeURL)
    
    func setBackgroundColor(blockIds: [BlockId], color: BlockBackgroundColor)
    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor)
    func checked(blockId: BlockId, newValue: Bool)
    func duplicate(blockId: BlockId)
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws
    func merge(secondBlockId: BlockId)
    func setObjectType(type: ObjectType) async throws
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: AnytypeURL
    )
}

extension BlockActionServiceProtocol {
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition) {
        add(info: info, targetBlockId: targetBlockId, position: position, setFocus: true)
    }
}
