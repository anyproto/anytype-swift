import BlocksModels
import UIKit
import ProtobufMessages

protocol BlockActionServiceProtocol {
    
    func upload(blockId: BlockId, filePath: String)
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition)
    func addChild(info: BlockInformation, parentId: BlockId)
    
    func delete(blockId: BlockId)
    
    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId?
    
    func split(
        _ string: NSAttributedString,
        blockId: BlockId,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        position: Int,
        newBlockContentType: BlockText.Style
    )
    
    func bookmarkFetch(blockId: BlockId, url: String)
    
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor)
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor)
    
    func checked(blockId: BlockId, newValue: Bool)
    
    func duplicate(blockId: BlockId)
    
    func setFields(contextID: BlockId, blockFields: [BlockFields])

    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString)
    @discardableResult
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool
    func merge(secondBlockId: BlockId)
    
    func setObjectTypeUrl(_ objectTypeUrl: String)
    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    )
}
