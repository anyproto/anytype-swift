import BlocksModels
import UIKit
import ProtobufMessages

protocol BlockActionServiceProtocol {

    func upload(blockId: BlockId, filePath: String)
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool)
    func addChild(info: BlockInformation, parentId: BlockId)
    
    func delete(blockIds: [BlockId])

    func createPage(targetId: BlockId, type: ObjectTypeUrl, position: BlockPosition) -> BlockId?
    
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
    
    func setFields(blockFields: BlockFields, blockId: BlockId)

    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString)
    @discardableResult
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool
    func merge(secondBlockId: BlockId)
    
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func setObjectSetType() -> BlockId

    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    )
}

extension BlockActionServiceProtocol {
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition) {
        add(info: info, targetBlockId: targetBlockId, position: position, setFocus: true)
    }
}
