import BlocksModels
import UIKit

protocol BlockActionServiceProtocol {
    
    func upload(blockId: BlockId, filePath: String)
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition)
    func addChild(info: BlockInformation, parentId: BlockId)
    
    func delete(blockId: BlockId)
    
    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId?
    
    func split(info: BlockInformation, position: Int, newBlockContentType: BlockText.Style, attributedString: NSAttributedString)
    
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
}
