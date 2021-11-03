import BlocksModels
import UIKit

protocol BlockActionServiceProtocol {
    
    func upload(blockId: BlockId, filePath: String)
    
    func turnInto(blockId: BlockId, type: BlockContentType)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool)
    func addChild(info: BlockInformation, parentBlockId: BlockId)
    
    func delete(blockId: BlockId, previousBlockId: BlockId?)
    
    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId?
    
    func split(info: BlockInformation, oldText: String, newBlockContentType: BlockText.Style)
    
    func bookmarkFetch(blockId: BlockId, url: String)
    
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor)
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor)
    
    func checked(blockId: BlockId, newValue: Bool)
    
    func duplicate(blockId: BlockId)
    
    func setFields(contextID: BlockId, blockFields: [BlockFields])
    
    func receivelocalEvents(_ events: [LocalEvent])
    
    func setObjectTypeUrl(_ objectTypeUrl: String)
}
